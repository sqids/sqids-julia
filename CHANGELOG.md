# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2021-09-10

### Changed

- Implementation changes due to modifications in the common specifications (simplification, performance improvement, see: [Simpler · Issue #11 · sqids/sqids-spec](https://github.com/sqids/sqids-spec/issues/11)). This is a breaking change and is not backward compatible with v0.2.x and earlier versions. ([#8](https://github.com/sqids/sqids-julia/pull/8))

## [0.2.1] - 2021-09-01

### Fixed

- Blocklist filtering in uppercase-only alphabet (see [sqids-spec PR #7](https://github.com/sqids/sqids-spec/pull/7)) ([#7](https://github.com/sqids/sqids-julia/pull/7))

## [0.2.0] - 2021-08-11

### Added

- Test for decoding an invalid ID with a [repeating reserved character](https://github.com/sqids/sqids-spec/commit/f52b57836b0463097018f984f853b284e50a5ce4) and implementation ([#5](https://github.com/sqids/sqids-julia/pull/5))

## [0.1.0] - 2021-07-15

### Added

- First implementation of [the spec](https://github.com/sqids/sqids-spec)

[0.3.0]: https://github.com/sqids/sqids-julia/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/sqids/sqids-julia/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/sqids/sqids-julia/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/sqids/sqids-julia/releases/tag/v0.1.0
