# Changelog

All notable changes to this project will be documented in this file.

<!-- markdownlint-disable no-duplicate-heading -->
<!-- markdownlint-disable emph-style -->
<!-- markdownlint-disable strong-style -->

## [0.5.4.0] _2026-07-10_

### 🚀 Features

-   Bind pactffi_add_interaction_reference

### 🐛 Bug Fixes

-   Add logger dependency for Ruby 4.0

### 🚜 Refactor

-   Replace bash download scripts with Ruby

### 📚 Documentation

-   Update developer documentation
-   Note the FFI version is derived from version.rb

### 🛠️ Miscellaneous Tasks

-   Remove legacy files
-   Add release tooling
-   _(ci)_ Modernise test matrix and add PR-driven release workflow
-   Fix buffer limit on Alpine Ruby 3.3
-   _(ci)_ Minor refactor
-   Add ruby version file

### Contributors

-   @JP-Ellis

## [0.5.3.0] _2026-02-23_

### 📦 Other

-   Create publish workflow
-   Update API token reference

### 🛠️ Miscellaneous Tasks

-   Bump version to 0.5.3.0
-   _(ci)_ Add ruby-version to publish workflow [skip ci]
-   _(ci)_ Add blank audience [skip ci]
-   _(ci)_ Add publish step [skip ci]

### Contributors

-   @YOU54F
-   @Copilot

## [0.4.28.0] _2025-08-29_

### 📦 Other

-   Update to libpact_ffi-0.4.28

### 🛠️ Miscellaneous Tasks

-   Only download standalone as it contains rust tools now

### Contributors

-   @YOU54F

## [0.4.26.0] _2024-12-21_

### 🚀 Features

-   Pact-ruby ffi
-   Add specs to test
-   _(ci)_ Test crossplatform
-   _(examples)_ Add init grpc.io ruby example
-   _(examples)_ Add area calculator grpc / test with pact plugin
-   Run plugin in CI
-   Test/publish/verify x-plat
-   All fully converted ffi lib
-   Rework for release
-   Release multi-arch gems
-   Support alpine/musl targets
-   Add basic V1 consumer example
-   Add basic fixture
-   Setup features under spec version/feature type
-   Add V1 scenarios for unexpected requests + requests with query parameters
-   Add remaining V1 HTTP consumer scenarios
-   Add V1 HTTP provider feature
-   Add V1 HTTP provider examples using a Pact broker
-   Correct the V1 HTTP provider feature
-   Add scenarios for dealing with provider states
-   Add scenarios for no provider state callback configured + request filters
-   Add initial V2 HTTP scenarios
-   _(V1)_ Add scenarios for verifying different HTTP response parts
-   _(V2)_ Add scenarios for matching rules on different HTTP response parts
-   _(V2)_ Add fixtures for matching rules on different HTTP response parts
-   _(V2)_ Add scenarios for matching rules when verifying different HTTP response parts
-   _(V2)_ Add negative scenario for repeated request query parameters
-   _(V1)_ Add scenarios for other content types than JSON
-   _(V1)_ Add scenarios for multipart bodies
-   Add remaining V2 provider scenarios
-   Add V3 HTTP + JSON features
-   Add V3 matching rule scenarios
-   Add V3 generator scenarios
-   Add V3 HTTP generator scenarios
-   Update V3 features and fixtures
-   Add V3 message consumer feature
-   Add V3 message provider feature
-   Add V4 features
-   Add missing V3 matching rule scenarios
-   Add V3 generator and matching rule scenarios
-   Update V4 mismatch errors
-   Add V4 message scenarios
-   Add Synchronous Messages feature
-   Add interaction description to the published verification results
-   Add some more ffi methods
-   Add x64-mingw32 platform

### 🐛 Bug Fixes

-   Use uint32 on windows as uint32_t not avail
-   Content_type_detection_plus_aarch64_musl_so
-   Correct the pact broker fixtures to be inline with Pact-Rust
-   Correct regex in the pact-broker_c1 fixture
-   Correct the error messages in V2 HTTP consumer scenarios
-   Correct V1 error message, which was not consistent with V3
-   Correct grammar in error messages
-   Update error steps to support regexes due to optional spaces
-   Small typos + added message tag
-   Add missing fixture file
-   Make empty body explicit
-   Ffi interface fixes

### 📚 Documentation

-   Add some doccos :)
-   Update compat table

### 🧪 Testing

-   Add calculateOne test
-   Refactor server to be started outside of test
-   Add pact-compatibility-suite partially impl v4 spec
-   _(ci)_ Add compat-suite to ci
-   Replace sleep with healthchecks

### 📦 Other

-   Download libs for grpc example and test x rubies
-   X-plat build/test - windows dll name
-   Testy:
-   Winnebago:
-   Cirrus arm64 + osx arm64 install rspec
-   Cirrus arm64 lookup
-   Test grpc on arm64
-   Test grpc on arm64
-   _(test)_ Add sleep as set path sep for windows
-   Alpine qemu slow so increase healthcheck duration
-   Macos-12 -> macos-13
-   Exclude grpc tests on linux/macos ruby 3.0

### 🛠️ Miscellaneous Tasks

-   Bundle on relative path not abs
-   Use libs in users home folder
-   Libpact_ffi-v0.4.4 - fiddle + arm64 aarch workaround
-   Libpact_ffi-v0.4.4 - fiddle + arm64 aarch workaround
-   Release 0.0.3
-   Release 0.0.3
-   Fixup grpc test
-   Dont clobber defs
-   Use webrick over thin
-   Revert back to pf releases post libpact_ffi 0.4.21 release
-   Minor update
-   Re-arrange feature layout
-   Add pact-foundation triage automation
-   Correct V3 content type matcher scenarios
-   Remove duplicated scenarios
-   Add @wip tag to Kafka scenario
-   Add smartbear supported jira integration
-   Compat suite subtree
-   Revert to pact-foundation libpact_ffi releases
-   _(test)_ Add basic-server
-   _(win)_ Sleep 2 use localhost for verifier
-   _(release)_ 0.4.22 - musl support
-   Fix plugin should be uint16 not pointer
-   Update rel script to grab version from version.rb

### Contributors

-   @YOU54F
-   @mefellows
-   @rholshausen
-   @tienvx

<!-- generated by git-cliff on 2026-06-19-->
