# Compatibility Policy

`canopy.v1` is the current wire-compatibility boundary.

## Compatible Changes

- Additive fields, messages, enum values, and RPCs preserve proto3 default behavior for older consumers.
- Existing field numbers and names are never reused.
- Removed fields are reserved by both number and name.
- Optional fields distinguish absence from a default value.
- Consumers tolerate unknown enum values, unknown fields, absent optional fields, and additional oneof variants.
- Consumers fail closed when an unknown value or variant affects authentication, authorization, or another security decision.

## Breaking Changes

An incompatible redesign uses a new protobuf package such as `canopy.v2`.
Package versions coexist during migration; a released `canopy.v1` wire promise
is not silently repurposed.

Buf `FILE` breaking checks run against the pull-request base and released BSR
history. Compatibility checks supplement review; they do not replace semantic
review of comments and consumer guidance.

## Releases And Pins

BSR labels such as `main` and `v0.2.0` are discovery references. Consumers pin
immutable generated SDK versions so builds do not change when a label moves.
A contract release describes protocol availability; it does not assert that a
particular server deployment implements that release.

## Deprecation

Deprecation requires all of the following:

1. A leading protobuf deprecation comment explaining the replacement.
2. A changelog entry.
3. At least one compatible release in which the old and replacement surfaces coexist.
4. Removal only in a new protobuf package version.
