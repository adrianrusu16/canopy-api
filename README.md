# Canopy API

The product-neutral, versioned protobuf contract for Canopy clients and server
implementations. The current public package is `canopy.v1` and is published to
the Buf Schema Registry (BSR) as a private module.

## Contract at a glance

| Item | Location |
| --- | --- |
| Canonical schema | [`proto/canopy/v1/canopy.proto`](proto/canopy/v1/canopy.proto) |
| BSR module | `buf.build/pandawave/canopy-api` |
| Stable release | `v0.2.0` (`145678c1d73e45b7bbaebf7e16ee4d64`) |
| Consumer integration | [`docs/consumer-guide.md`](docs/consumer-guide.md) |
| Compatibility rules | [`docs/compatibility.md`](docs/compatibility.md) |
| Release history | [`CHANGELOG.md`](CHANGELOG.md) |

The protobuf source and its BSR documentation are authoritative. This
repository defines wire shapes and their product-neutral semantics; server
endpoints, transport security, deployment settings, delivery channels, and UI
behavior belong to the implementation or its consumers.

## Service surface

| Service | Purpose | Access |
| --- | --- | --- |
| `CatalogService` | Browse, search, and retrieve catalog metadata. | Anonymous-capable |
| `PlaybackService` | Resolve an opaque, expiring playback source. | Anonymous-capable |
| `DiscoveryService` | Get discovery, For You, and recommendations feeds. The latter two currently retain discovery ordering. | Anonymous-capable |
| `ProfileService` | Create, read, update, and delete a profile; manage preferences. | Authenticated profile |
| `HistoryService` | Manage playback-history consent and entries. Disabling history purges it. | Authenticated profile |
| `LibraryService` | Manage saved tracks and likes. | Authenticated profile |
| `PlaylistService` | Manage playlists and their ordered track membership. | Authenticated profile |
| `AuthService` | Manage credentials, email verification, Google identity, sessions, and account lifecycle. | Bootstrap and authenticated methods |
| `SystemService` | Retrieve application and dependency status. | Public |

Anonymous-capable RPCs may receive bearer metadata. Invalid supplied metadata
returns `UNAUTHENTICATED`; it never falls back to anonymous access. Protected
calls require lowercase `authorization` metadata containing
`Bearer <access-token>`. See the [consumer guide](docs/consumer-guide.md) for
the per-method authorization table, session lifecycle, input policy, error
handling, and a Tonic example.

## Use the generated SDKs

The BSR publishes generated SDKs. Consumers should discover releases by label,
but pin the generated packages to exact immutable versions so that builds do
not change when a label moves. For the private Buf Cargo registry setup and
current Rust package coordinates, follow the
[consumer guide](docs/consumer-guide.md#rust-sdk-setup).

Consumers treat page tokens, identifiers, and playback URLs as opaque;
preserve unknown protobuf fields and preference keys. Branch on canonical gRPC
status codes rather than backend message text.

## Development

Install a compatible [Buf CLI](https://buf.build/docs/installation/) and run
the complete local contract check before opening a pull request:

```bash
buf format --diff --exit-code
buf lint
buf build
bash scripts/check-contract-boundary.sh
```

CI runs the same checks for pushes and pull requests. Pull requests also run
`buf breaking` against their Git base; pushes are checked against the stable
BSR release before publication. The CI workflow installs a checksum-pinned Buf
CLI and keeps the BSR credential confined to publication and label-archival
steps.

## Versioning and releases

Backward-compatible additions remain in `canopy.v1`. Breaking redesigns use a
new protobuf package version, such as `canopy.v2`; released `canopy.v1` wire
semantics are never repurposed. Before changing the contract, read
[CONTRIBUTING.md](CONTRIBUTING.md), update protobuf comments and consumer
documentation with the schema, add a [changelog](CHANGELOG.md) entry, and run
the validation commands above.

See the [compatibility policy](docs/compatibility.md) for additive-change,
deprecation, and consumer-upgrade rules.
