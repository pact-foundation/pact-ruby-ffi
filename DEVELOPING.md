# Developing

## Setup

```sh
bundle install
make download_libs
```

## Running tests

```sh
make test                  # unit tests
make compat_suite_test_v4  # compatibility suite
make grpc                  # gRPC plugin demo (see examples/area_calculator/DEVELOPING.md)
```

## Releasing

Releases are fully automated via the PR-driven flow in `.github/workflows/release.yml`.

The gem version is `{ffi}.{N}`, where the first three components mirror the latest [`libpact_ffi`](https://github.com/pact-foundation/pact-reference/releases) release that the gem wraps, and `{N}` is a wrapper-only revision. `{N}` resets to `0` when a new upstream `libpact_ffi` is released and increments otherwise. This keeps the gem tracking upstream FFI releases automatically.

1. **On every push to `main`**, the `prepare` job runs `script/release.rb prepare`, which looks up the latest upstream `libpact_ffi` release, computes the next version from it, updates the FFI pin (`script/lib/export-binary-versions.sh`), `lib/pact/ffi/version.rb`, and `CHANGELOG.md` (changelog body via git-cliff), force-pushes to `release/pact-ffi`, and creates or updates a **draft** release PR.

2. **When ready to release**, promote the PR from draft → ready-for-review. This triggers CI including a full multi-platform gem build dry-run. You can edit `version.rb` or `CHANGELOG.md` directly on the `release/pact-ffi` branch to make manual adjustments — those files are the source of truth. **Caution:** any new push to `main` while the PR is open will re-run `prepare` and force-push the computed version/changelog over any manual edits.

3. **Merging the PR** triggers the `tag` job, which reads the version from `version.rb` and pushes a `v{version}` tag.

4. **The tag push** triggers the `publish` job: runs tests, downloads all native FFI libs, builds all platform gems, creates a GitHub Release, and pushes to RubyGems via OIDC (no stored API key required).

### One-time setup (already done once per gem)

Configure OIDC trusted publishing on [rubygems.org](https://rubygems.org) for the `pact-ffi` gem, trusting the `publish` job in `pact-foundation/pact-ruby-ffi`.

## gRPC / Protobuf plugin development

See [`examples/area_calculator/DEVELOPING.md`](examples/area_calculator/DEVELOPING.md).
