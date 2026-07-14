# Canopy API

Product-neutral protobuf contract published as `canopy.v1`.

## Contract

- Canonical source: `proto/canopy/v1/canopy.proto`
- Private BSR module: `buf.build/pandawave/canopy-api`
- Current stable release: `v0.2.0`
- Immutable stable commit: `145678c1d73e45b7bbaebf7e16ee4d64`
- Consumer setup: `docs/consumer-guide.md`
- Compatibility policy: `docs/compatibility.md`

Protobuf and BSR documentation are authoritative. Consumers pin immutable
generated SDK versions and treat server endpoints and deployment configuration
as implementation-provided settings.

## Validate

```bash
buf format --diff --exit-code
buf lint
buf build
bash scripts/check-contract-boundary.sh
```

## Releases

Backward-compatible changes remain in `canopy.v1`. Breaking redesigns use a
new protobuf package version. See `CHANGELOG.md` and `docs/compatibility.md`.
