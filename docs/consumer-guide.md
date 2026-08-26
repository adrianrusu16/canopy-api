# Consumer Guide

This guide describes the released `canopy.v1` contract for any gRPC consumer.
The protobuf source and its Buf Schema Registry documentation are authoritative.
An implementation supplies its own endpoint, transport security, and delivery
configuration.

## Authority And Discovery

- Canonical source: `proto/canopy/v1/canopy.proto`.
- BSR module: `buf.build/pandawave/canopy-api`.
- Current stable release: `v0.3.0`.
- Immutable stable commit: `ff8940d1a15b4034bb430fd47dd45cdc`.
- BSR hosts versioned schema documentation and generated SDKs.
- OpenAPI is not used to generate gRPC clients.

## Rust SDK Setup

Configure the private Buf Cargo registry in `.cargo/config.toml`:

```toml
[registries.buf]
index = "sparse+https://buf.build/gen/cargo/"
credential-provider = "cargo:token"
```

Authenticate a local Cargo installation with a personal registry token:

```bash
cargo login --registry buf "Bearer {token}"
```

Pin generated packages to immutable versions:

```toml
[dependencies]
canopy-api-prost = { package = "pandawave_canopy-api_community_neoeinstein-prost", version = "=0.5.0-00000000000000-ff8940d1a15b.2", registry = "buf" }
canopy-api-tonic = { package = "pandawave_canopy-api_community_neoeinstein-tonic", version = "=0.5.0-00000000000000-ff8940d1a15b.4", registry = "buf" }
tonic = { version = "0.14.6", features = ["transport"] }
```

Release labels are useful for discovery. Exact generated SDK versions are the
reproducible dependency boundary.

## Channel And Metadata

The implementation supplies the gRPC endpoint and trust configuration.
Protected calls carry the lowercase metadata key `authorization` with the
value `Bearer <access-token>`.

Absent authorization metadata is anonymous only on anonymous-capable RPCs.
Malformed or invalid supplied metadata returns `UNAUTHENTICATED`; it never
downgrades the request to anonymous access.

## Discovery-family feeds

`GetDiscoveryFeed`, `GetForYouFeed`, and `GetRecommendations` are
anonymous-capable, use opaque pagination, and accept best-effort track
exclusions. The initial `For You` and recommendations responses intentionally
use the same ordering as discovery; consumers must not infer personalized
ranking until a later contract note says it is available.

## Service Authorization

| Surface | Authorization |
| --- | --- |
| `CatalogService`, `DiscoveryService`, `PlaybackService` | Anonymous-capable; a valid bearer token may add identity context. |
| `SystemService.GetStatus` | Public status method. |
| `AuthService.RegisterPassword`, `ResendVerification`, `VerifyEmail`, `LoginPassword`, `RequestPasswordReset`, `CompletePasswordReset`, `BeginGoogleLogin`, `CompleteGoogleLogin`, `RefreshSession` | Public authentication bootstrap; bearer metadata is not required. |
| `AuthService.ChangePassword`, `LinkGoogle`, `UnlinkGoogle`, `Logout`, `LogoutAll`, `ListSessions`, `RevokeSession`, `GetAccount`, `DeleteAccount` | Valid bearer metadata is required. |
| Every `ProfileService`, `HistoryService`, `LibraryService`, and `PlaylistService` RPC | Valid bearer metadata and an existing profile are required. |

## Session Lifecycle

`SessionEnvelope` is returned only after successful email verification,
password login, Google login, or refresh. Treat its access token, refresh
token, both expiration fields, account, and session as one atomic value. Store
or replace them together.

Allow only one refresh request in flight for a session. A successful refresh
rotates the refresh token. Concurrent or repeated use of an old token can
revoke the session family. If the transport result is ambiguous after a
refresh request was sent, do not retry the same refresh token; require the user
to authenticate again.

Password reset, logout-all, and account deletion invalidate all sessions;
clear local credentials after these operations succeed. Password change keeps
the authenticated current session active while invalidating the account's
other sessions. Logout and session revocation are safe to treat as idempotent
from the consumer's point of view.

## Authentication Input Policy

- New and replacement passwords contain 8 through 64 Unicode scalar values.
- Login and current-password fields accept an existing non-empty credential;
  consumers must not apply the creation bounds to credentials created under an
  earlier policy.
- Email input is trimmed and compared case-insensitively. It contains exactly
  one `@`, a common ASCII local part with no leading, trailing, or repeated dot,
  and DNS-style domain labels with no leading or trailing hyphen. The full
  address is at most 254 UTF-8 bytes, the local part at most 64 bytes, the
  domain at most 253 bytes, and each domain label at most 63 bytes.
- Treat `INVALID_ARGUMENT` as a field or policy rejection, but never parse the
  backend message to decide application behavior.
- Bound client call duration and allow only explicit, operation-aware retries.
  Never automatically replay an account-creation, login, password-change,
  password-reset, or refresh request after an ambiguous transport result.

## Google Login And Linking

1. Call `BeginGoogleLogin`.
2. Bind the returned nonce to the identity-provider request.
3. Submit the resulting ID token and challenge ID to `CompleteGoogleLogin`.
4. Handle every `GoogleLoginResponse.result` oneof variant.

When the response contains `account_link_required`, authenticate the existing
account and call protected `LinkGoogle` with the returned link challenge.
Fail closed if a future oneof variant is unknown to the consumer.

## Out-Of-Band Challenges

Verification and password-reset tokens arrive through an
implementation-owned delivery channel. Pass each token unchanged to
`VerifyEmail` or `CompletePasswordReset`. The contract intentionally does not
define email URLs, custom URI schemes, or application deep-link formats.

## Errors

Branch on canonical gRPC status codes, never message text:

| Code | Contract meaning |
| --- | --- |
| `INVALID_ARGUMENT` | The request is malformed or violates field constraints. |
| `UNAUTHENTICATED` | Credentials are absent where required, malformed, invalid, expired, or revoked. |
| `PERMISSION_DENIED` | The authenticated principal cannot perform the operation. |
| `NOT_FOUND` | The resource is absent or intentionally concealed. |
| `ALREADY_EXISTS` | A unique resource or relationship already exists and the method is not idempotent. |
| `FAILED_PRECONDITION` | Current resource state prevents the operation. |
| `ABORTED` | A concurrency precondition failed; refetch before reconciling. |
| `RESOURCE_EXHAUSTED` | A quota or abuse-control limit was reached. |
| `UNAVAILABLE` | A required service is temporarily unavailable. |
| `INTERNAL` | The operation failed without a consumer-actionable detail. |

`RESOURCE_EXHAUSTED` does not currently guarantee structured retry metadata.
Use bounded backoff and avoid retrying non-idempotent operations blindly.

## Pagination And Resources

- Page tokens are opaque. Return them unchanged and never parse them.
- `page_size = 0` selects the server default; implementations may clamp larger values.
- Persisted instants use `google.protobuf.Timestamp` in UTC.
- Session-envelope expiration fields use Unix epoch milliseconds.
- Media durations and positions use milliseconds.
- Optional fields distinguish absence from a scalar or message default.
- `PlaybackSource.stream_url` is opaque and usable verbatim only until `expires_at`.
- `PlaybackSource` format, bitrate, and content type describe the selected playback asset.
- `ArtworkRef.id` is an opaque stable artwork resource identifier. It must not be
  treated as a loadable URI, filesystem path, or object-storage key.
- `ArtworkRef.content_hash` is the lowercase SHA-256 hex digest of the artwork
  bytes and is the content-version / cache key. When bytes behind the same
  artwork id are replaced, `id` stays stable and `content_hash` changes.
- Consumers derive artwork display URLs from their configured media origin plus
  `ArtworkRef` (for example `/artwork/{id}/{content_hash}`). The contract never
  embeds platform URI schemes or CDN hostnames in artwork fields.
- Saved, liked, and playlist-track list entries include renderable track data plus relationship metadata.
- Playlist reorder sends the complete ordered membership and `expected_revision`.
- A playlist reorder returning `ABORTED` means refetch, reconcile, and submit a new complete order.
- Consumers preserve unknown protobuf fields and application-defined preference keys.

## Tonic Request Example

```rust
use canopy_api_prost::canopy::v1::GetAccountRequest;
use canopy_api_tonic::canopy::v1::tonic::auth_service_client::AuthServiceClient;
use tonic::{Request, metadata::MetadataValue, transport::Channel};

async fn get_account(
    client: &mut AuthServiceClient<Channel>,
    access_token: &str,
) -> Result<(), tonic::Status> {
    let mut request = Request::new(GetAccountRequest {});
    let authorization = MetadataValue::try_from(format!("Bearer {access_token}"))
        .map_err(|_| tonic::Status::invalid_argument("invalid access token metadata"))?;
    request
        .metadata_mut()
        .insert("authorization", authorization);
    client.get_account(request).await?;
    Ok(())
}
```

## Compatibility

See [Compatibility](compatibility.md) before upgrading. Consumers should
review the changelog, update all generated packages for a schema commit
together, regenerate any local adapters, and run their own integration tests.
