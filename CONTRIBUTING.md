# Contributing

Changes to this repository change a released protocol promise. Keep contract
documentation product-neutral and place deployment or consumer-specific
behavior in the repository that owns it.

## Ownership

| Claim | Owner | Verification |
| --- | --- | --- |
| Wire shape and field semantics | `canopy-api` | `buf lint`, `buf build`, `buf breaking` |
| Contract auth/error/pagination behavior | `canopy-api` | protobuf comments and consumer guide review |
| Generated SDK publication | `canopy-api` | BSR push and generated SDK availability |
| Server support and deployment behavior | server implementation | server conformance and integration tests |
| Consumer storage, UI, and CI/CD | each consumer | consumer integration tests |

## Release Checklist

1. Update protobuf comments with every behavioral contract change.
2. Update product-neutral consumer documentation.
3. Update `CHANGELOG.md`.
4. Run `buf format --diff --exit-code`, `buf lint`, `buf build`, the relevant `buf breaking` check, and `bash scripts/check-contract-boundary.sh`.
5. Merge only after contract review and successful checks.
6. Let repository CI check the accepted schema against the current stable BSR release and publish it.
7. Create a Git tag only when intentionally applying a matching release label.

Contract publication, server rollout, and consumer rollout are independent
events. Automation may publish schema artifacts and immutable version metadata;
it must not copy prose into implementation or consumer repositories.

## CI Credential Boundary

- `BUF_TOKEN` is a repository secret used only by the checksum-verified Buf CLI for `buf push` and deleted-label archival.
- The workflow pins Buf `1.71.0` and verifies the official Linux x86_64 SHA-256 checksum before execution.
- Pull requests, including pull requests from forks, run format, lint, build, boundary, and Git-base compatibility checks without receiving `BUF_TOKEN`.
- The secret exists only in the publication or archival step environment and is discarded with that step.
- No third-party GitHub Action receives `BUF_TOKEN`.
- The BSR module must already exist because publication never passes `--create`.
