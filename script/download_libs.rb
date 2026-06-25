#!/usr/bin/env ruby
# frozen_string_literal: true

# Downloads the native libpact_ffi libraries (and the pact standalone CLI used
# by the gRPC example) into the working tree.
#
#   ruby script/download_libs.rb          # current platform only
#   ruby script/download_libs.rb --all    # every published platform
#
# The libpact_ffi version is derived from lib/pact/ffi/version.rb — the first
# three version components mirror the upstream release. The standalone CLI
# tracks its own upstream and is pinned here.

require 'fileutils'
require 'zlib'
require_relative 'lib/platforms'
require_relative '../lib/pact/ffi/version'

ROOT                = File.expand_path('..', __dir__)
FFI_BASE_URL        = 'https://github.com/pact-foundation/pact-reference/releases/download'
STANDALONE_BASE_URL = 'https://github.com/pact-foundation/pact-standalone/releases/download'
STANDALONE_VERSION  = '2.5.2'

# Standalone publishes one binary per OS/arch (no musl variant); musl hosts use
# the glibc build, matching the previous shell behaviour.
STANDALONE_ASSETS = {
  'macos-arm64'      => "pact-#{STANDALONE_VERSION}-osx-arm64.tar.gz",
  'macos-x64'        => "pact-#{STANDALONE_VERSION}-osx-x86_64.tar.gz",
  'linux-arm64'      => "pact-#{STANDALONE_VERSION}-linux-arm64.tar.gz",
  'linux-arm64-musl' => "pact-#{STANDALONE_VERSION}-linux-arm64.tar.gz",
  'linux-x64'        => "pact-#{STANDALONE_VERSION}-linux-x86_64.tar.gz",
  'linux-x64-musl'   => "pact-#{STANDALONE_VERSION}-linux-x86_64.tar.gz",
  'windows-x64'      => "pact-#{STANDALONE_VERSION}-windows-x86_64.zip"
}.freeze

def log(msg) = puts "🔵  #{msg}"

def ffi_version
  "v#{Pact::Version::VERSION.split('.')[0..2].join('.')}"
end

# The native lib directory matching the running Ruby. RUBY_PLATFORM is the
# authoritative signal (it encodes musl) and is portable, unlike `uname`.
def current_dir
  case RUBY_PLATFORM
  when /musl/        then RUBY_PLATFORM.match?(/aarch64|arm64/) ? 'linux-arm64-musl' : 'linux-x64-musl'
  when /linux/       then RUBY_PLATFORM.match?(/aarch64|arm64/) ? 'linux-arm64' : 'linux-x64'
  when /darwin/      then RUBY_PLATFORM.match?(/aarch64|arm64/) ? 'macos-arm64' : 'macos-x64'
  when /mingw|mswin/ then 'windows-x64'
  else abort "❌  Unsupported platform: #{RUBY_PLATFORM}"
  end
end

def fetch(url, dest)
  FileUtils.mkdir_p(File.dirname(dest))
  log "Downloading #{url}"
  abort "❌  Failed to download #{url}" unless
    system('curl', '--silent', '--show-error', '--fail', '--location', '--output', dest, url)
end

def fetch_gz(url, dest)
  gz = "#{dest}.gz"
  fetch(url, gz)
  File.open(dest, 'wb') do |out|
    Zlib::GzipReader.open(gz) do |reader|
      while (chunk = reader.read(65_536))
        out.write(chunk)
      end
    end
  end
  File.delete(gz)
end

def download_ffi(all:)
  ffi_dir = File.join(ROOT, 'ffi')
  log "Cleaning #{ffi_dir}"
  FileUtils.rm_rf(ffi_dir)

  libs = all ? Pact::Ffi::NATIVE_LIBS : [Pact::Ffi.native_lib(current_dir)]
  libs.each do |native|
    fetch_gz("#{FFI_BASE_URL}/libpact_ffi-#{ffi_version}/#{native[:asset]}",
             File.join(ffi_dir, native[:dir], native[:lib]))
  end

  %w[pact.h pact-cpp.h].each do |header|
    fetch("#{FFI_BASE_URL}/libpact_ffi-#{ffi_version}/#{header}", File.join(ffi_dir, header))
  end

  File.write(File.join(ffi_dir, 'README.md'),
             "# FFI binaries\n\nThis folder is automatically populated by script/download_libs.rb\n")
end

def download_standalone
  dir    = File.join(ROOT, 'pact', 'standalone')
  marker = File.join(dir, '.version')
  if File.exist?(marker) && File.read(marker).strip == STANDALONE_VERSION
    log "Standalone #{STANDALONE_VERSION} already present — skipping"
    return
  end

  FileUtils.rm_rf(dir)
  FileUtils.mkdir_p(dir)
  asset   = STANDALONE_ASSETS.fetch(current_dir)
  archive = File.join(dir, asset)
  log "Downloading standalone #{STANDALONE_VERSION}"
  fetch("#{STANDALONE_BASE_URL}/v#{STANDALONE_VERSION}/#{asset}", archive)

  extracted =
    if asset.end_with?('.zip')
      system('unzip', '-qo', archive, '-d', dir)
    else
      system('tar', '-xf', archive, '-C', dir)
    end
  abort "❌  Failed to extract #{archive}" unless extracted

  File.delete(archive)
  File.write(marker, STANDALONE_VERSION)
end

download_ffi(all: ARGV.include?('--all'))
download_standalone
log 'Done'
