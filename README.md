# Canopy API

Canonical protobuf contract for Canopy and PandaEngine.

- `proto/canopy/v1/canopy.proto` is authoritative.
- `openapi/openapi.json` is a noncanonical documentation companion.
- Backward-compatible changes remain in `canopy.v1`.
- Breaking redesigns use a new protobuf package version.


## Implementation Status

Canopy currently consumes this contract through the generated BSR SDK. Native email/password registration, email verification, password login, refresh-token rotation, password reset/change, verification resend, account lookup/deletion, session listing/revocation, Google login/linking, and durable profile/history/library/likes/preferences/playlist RPC authentication are implemented or wired in Canopy. Google ID-token verification is enabled in PostgreSQL mode when Canopy is configured with accepted Google OAuth client IDs; otherwise Google login fails closed. Full downstream PandaEngine adoption remains follow-up work. Auth abuse controls now throttle repeated registration/login/resend/reset attempts and record refresh-token reuse signals without storing raw subjects.

Canopy still lacks the supervised SMTP worker that delivers committed authentication outbox rows. Verification and password-reset messages are authenticated-encrypted at rest and remain queued; this is runtime implementation work and does not require a protobuf contract change.

Collection resource shapes in `canopy.v1` are canonical: saved-track, liked-track, and playlist-track list responses carry renderable track summaries plus relationship metadata such as `saved_at`, `liked_at`, `position`, and `added_at`.

## Validate

```bash
buf format --diff --exit-code
buf lint
buf build
```

## Publish

The private BSR module is `buf.build/pandawave/canopy-api`. Publication requires an authenticated Buf account with access to the `pandawave` organization.
