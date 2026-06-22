#!/usr/bin/env ruby
# frozen_string_literal: true

require 'open3'

RELEASE_BRANCH      = 'release/pact-ffi'
VERSION_FILE        = 'lib/pact/ffi/version.rb'
FFI_VERSION_FILE    = 'script/lib/export-binary-versions.sh'
UPSTREAM_REPO       = 'pact-foundation/pact-reference'
UPSTREAM_TAG_PREFIX = 'libpact_ffi-v'

def run!(*cmd)
  out, status = Open3.capture2e(*cmd)
  raise "Command failed: #{cmd.join(' ')}\n#{out}" unless status.success?

  out.strip
end

def run(*cmd)
  out, = Open3.capture2e(*cmd)
  out.strip
end

# The gem version is `{upstream}.{N}`, where the first three components mirror
# the latest libpact_ffi release and `{N}` is a wrapper-only revision. `{N}`
# resets to 0 on a new upstream release and increments otherwise.
def fetch_upstream_version
  jq = %([.[] | select(.tagName | startswith("#{UPSTREAM_TAG_PREFIX}"))] | first | .tagName)
  tag = run!('gh', 'release', 'list', '--repo', UPSTREAM_REPO, '--json', 'tagName', '--jq', jq)
  raise "No #{UPSTREAM_TAG_PREFIX}* release found in #{UPSTREAM_REPO}" if tag.empty? || tag == 'null'

  tag.delete_prefix(UPSTREAM_TAG_PREFIX)
end

def compute_wrapper_version(upstream, current)
  current_upstream = current.split('.')[0..2].join('.')
  if upstream == current_upstream
    "#{upstream}.#{current.split('.')[3].to_i + 1}"
  else
    "#{upstream}.0"
  end
end

def read_version
  File.read(VERSION_FILE)[/VERSION = '([^']*)'/, 1] or raise "Could not read version from #{VERSION_FILE}"
end

def prepare
  upstream = fetch_upstream_version
  current  = read_version
  bumped   = compute_wrapper_version(upstream, current)
  tag      = "v#{bumped}"

  if bumped == current
    puts "version.rb already at #{bumped} — nothing to do."
    return
  end

  puts "Preparing release #{tag} (upstream libpact_ffi #{upstream})..."

  File.write(VERSION_FILE, File.read(VERSION_FILE).sub(/VERSION = '[^']*'/, "VERSION = '#{bumped}'"))
  File.write(FFI_VERSION_FILE, File.read(FFI_VERSION_FILE).sub(/FFI_VERSION=\S+/, "FFI_VERSION=v#{upstream}"))

  run!('git', 'cliff', '--unreleased', '--tag', tag, '--prepend', 'CHANGELOG.md')

  run!('git', 'checkout', '-B', RELEASE_BRANCH, 'origin/main')
  run!('git', 'add', VERSION_FILE, FFI_VERSION_FILE, 'CHANGELOG.md')
  run!('git', 'commit', '-m', "chore: prepare release #{tag}")
  run!('git', 'push', '--force', 'origin', RELEASE_BRANCH)

  existing = run('gh', 'pr', 'list', '--head', RELEASE_BRANCH, '--state', 'open', '--json', 'number', '--jq', '.[0].number')
  if existing.empty? || existing == 'null'
    run!('gh', 'pr', 'create', '--draft', '--title', "chore: release #{tag}", '--body', '', '--head', RELEASE_BRANCH, '--base', 'main')
    puts "Created draft release PR for #{tag}"
  else
    run!('gh', 'pr', 'edit', existing, '--title', "chore: release #{tag}")
    puts "Updated release PR ##{existing} for #{tag}"
  end
ensure
  run('git', 'checkout', 'main')
end

def tag_release
  tag = "v#{read_version}"

  run!('git', 'fetch', '--tags', 'origin')
  unless run('git', 'tag', '-l', tag).empty?
    puts "Tag #{tag} already exists — nothing to do."
    return
  end

  puts "Tagging #{tag}..."
  run!('git', 'tag', tag)
  run!('git', 'push', 'origin', tag)
  puts "Pushed tag #{tag}"
end

case ARGV[0]
when 'prepare' then prepare
when 'tag'     then tag_release
else
  warn "Usage: #{$PROGRAM_NAME} prepare|tag"
  exit 1
end
