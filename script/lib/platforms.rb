# frozen_string_literal: true

module Pact
  module Ffi
    # The native libpact_ffi libraries shipped with the gem. `asset` is the
    # upstream pact-reference release asset (minus the version); once
    # downloaded and gunzipped it lands at `ffi/<dir>/<lib>`.
    NATIVE_LIBS = [
      { dir: 'linux-x64',        lib: 'libpact_ffi.so',    asset: 'libpact_ffi-linux-x86_64.so.gz' },
      { dir: 'linux-arm64',      lib: 'libpact_ffi.so',    asset: 'libpact_ffi-linux-aarch64.so.gz' },
      { dir: 'linux-x64-musl',   lib: 'libpact_ffi.so',    asset: 'libpact_ffi-linux-x86_64-musl.so.gz' },
      { dir: 'linux-arm64-musl', lib: 'libpact_ffi.so',    asset: 'libpact_ffi-linux-aarch64-musl.so.gz' },
      { dir: 'macos-x64',        lib: 'libpact_ffi.dylib', asset: 'libpact_ffi-macos-x86_64.dylib.gz' },
      { dir: 'macos-arm64',      lib: 'libpact_ffi.dylib', asset: 'libpact_ffi-macos-aarch64.dylib.gz' },
      { dir: 'windows-x64',      lib: 'pact_ffi.dll',      asset: 'pact_ffi-windows-x86_64.dll.gz' }
    ].freeze

    # Gem platforms built and published, each mapped to its native lib
    # directory above. The two Windows platforms share a single DLL.
    GEM_PLATFORMS = {
      'aarch64-linux'      => 'linux-arm64',
      'aarch64-linux-musl' => 'linux-arm64-musl',
      'arm64-darwin'       => 'macos-arm64',
      'x86_64-linux'       => 'linux-x64',
      'x86_64-linux-musl'  => 'linux-x64-musl',
      'x86_64-darwin'      => 'macos-x64',
      'x64-mingw-ucrt'     => 'windows-x64',
      'x64-mingw32'        => 'windows-x64'
    }.freeze

    module_function

    def native_lib(dir)
      NATIVE_LIBS.find { |l| l[:dir] == dir } || raise("Unknown ffi directory: #{dir}")
    end

    # The build targets for the Rakefile: one entry per published gem platform.
    def gem_build_targets
      GEM_PLATFORMS.map do |ruby_platform, dir|
        { ruby_platform: ruby_platform, ffi_location: dir, ffi_name: native_lib(dir)[:lib] }
      end
    end
  end
end
