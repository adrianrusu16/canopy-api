# Canopy API

Canonical protobuf contract for Canopy and PandaEngine.

- `proto/canopy/v1/canopy.proto` is authoritative.
- `openapi/openapi.json` is a noncanonical documentation companion.
- Backward-compatible changes remain in `canopy.v1`.
- Breaking redesigns use a new protobuf package version.

## Validate

```bash
buf format --diff --exit-code
buf lint
buf build
```

## Publish

The private BSR module is `buf.build/pandawave/canopy-api`. Publication requires an authenticated Buf account with access to the `pandawave` organization.