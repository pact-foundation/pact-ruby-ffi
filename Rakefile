require 'rspec/core/rake_task'
require 'rubygems/package'
require 'pact/ffi/version'
require_relative 'script/lib/platforms'
RSpec::Core::RakeTask.new(:spec)

task default: :spec

PLATFORMS = Pact::Ffi.gem_build_targets

task :build do
  gemspec = Gem::Specification.load('pact-ffi.gemspec')
  sh 'mkdir -p pkg'
  PLATFORMS.each do |platform|
    platform_gemspec = gemspec.clone
    puts platform_gemspec
    platform_gemspec.files.push(['ffi', platform[:ffi_location], platform[:ffi_name]].join('/'))
    puts platform_gemspec.name
    puts platform_gemspec.files
    platform_gemspec.platform = platform[:ruby_platform]
    Gem::Package.build(platform_gemspec)
    sh "mv #{platform_gemspec.name}-#{platform_gemspec.version}-#{platform[:ruby_platform]}.gem pkg/"
  end
end

task :clean do
  sh 'rm -rf pkg'
end

task :yank do
  Pact::Ffi::GEM_PLATFORMS.each_key do |platform|
    sh "gem yank pact-ffi -v #{Pact::Version::VERSION} --platform #{platform}"
  end
end

task :push do
  Pact::Ffi::GEM_PLATFORMS.each_key do |platform|
    sh "cd pkg && gem push pact-ffi-#{Pact::Version::VERSION}-#{platform}.gem"
  end
end
