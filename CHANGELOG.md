# Changelog

## Unreleased

- Add `ArtworkRef.content_hash` so artwork identity stays stable while content versioning remains explicit, without embedding client URIs or storage keys.
- Clarify that `ArtworkRef` remains platform-neutral: consumers derive display URLs from configured media origins, not from the contract.
- Add independent `GetForYouFeed` and `GetRecommendations` RPCs that initially mirror discovery without changing existing wire shapes.
- Separate product-neutral contract guidance from implementation and consumer documentation.
- Add a complete consumer guide, compatibility policy, ownership guard, and generated-documentation linting.

## v0.2.0 - 2026-07-11

- Add password, Google identity, account lifecycle, and per-device session RPCs to `canopy.v1.AuthService`.
- Add canonical saved-track, liked-track, and playlist-track resource shapes.

## v0.1.0 - 2026-07-03

- Establish the audited bounded-service `canopy.v1` contract.
