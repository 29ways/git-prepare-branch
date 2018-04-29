PACKAGE_NAME = 'git-prepare-branch'
VERSION = '0.1.0'
TRAVELING_RUBY_VERSION = '20150715-2.2.2'

require 'bundler'

desc 'Package your app'
task :package => ['package:linux:x86', 'package:linux:x86_64', 'package:osx']

namespace :package do
  namespace :linux do
    desc 'Package your app for Linux x86'
    task :x86 => [:bundle_install, "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86.tar.gz"] do
      create_package('linux-x86')
    end

    desc 'Package your app for Linux x86_64'
    task :x86_64 => [:bundle_install, "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz"] do
      create_package('linux-x86_64')
    end
  end

  desc 'Package your app for OS X'
  task :osx => [:bundle_install, "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx.tar.gz"] do
    create_package('osx')
  end

  desc "Install gems to local directory"
  task :bundle_install do
    if RUBY_VERSION !~ /^2\.2\./
      abort "You can only 'bundle install' using Ruby 2.2, because that's what Traveling Ruby uses."
    end

    # remove existing tmp folder
    sh "rm -rf packaging/tmp"

    # create new folder and copy over files necessary for installing dependencies
    sh "mkdir packaging/tmp"
    sh "cp Gemfile Gemfile.lock packaging/tmp/"
    sh 'cp *.gemspec packaging/tmp/'
    sh 'mkdir -p packaging/tmp/lib/git-prepare-branch'
    sh 'cp lib/git-prepare-branch/version.rb packaging/tmp/lib/git-prepare-branch'

    # Install the dependencies
    Bundler.with_clean_env do
      sh "cd packaging/tmp && env BUNDLE_IGNORE_CONFIG=1 bundle install --path ../vendor --without development"
    end

    sh "rm -rf packaging/tmp"
    sh "rm -f packaging/vendor/*/*/cache/*"
  end
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86.tar.gz" do
  download_runtime('linux-x86')
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz" do
  download_runtime('linux-x86_64')
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx.tar.gz" do
  download_runtime('osx')
end

def create_package(target)
  package_dir = "#{PACKAGE_NAME}-#{VERSION}-#{target}"
  # clear any existing package
  sh "rm -rf #{package_dir}"

  # make the folder for the source and copy over the appropriate folders
  sh "mkdir -p #{package_dir}/lib/app"
  sh "cp -R bin #{package_dir}/lib/app/"
  sh "cp -R lib #{package_dir}/lib/app/"

  # make the folder for the packaged ruby and copy it over
  sh "mkdir #{package_dir}/lib/ruby"
  sh "tar -xzf packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz -C #{package_dir}/lib/ruby"

  # copy over the wrapper script
  sh "cp packaging/wrapper.sh #{package_dir}/git-prepare-branch"

  # copy over the Ruby bundle and configuration
  sh "cp -pR packaging/vendor #{package_dir}/lib/"
  sh "cp Gemfile Gemfile.lock *.gemspec #{package_dir}/lib/vendor/"
  sh "mkdir -p #{package_dir}/lib/vendor/lib/git-prepare-branch"
  sh "cp lib/git-prepare-branch/version.rb #{package_dir}/lib/vendor/lib/git-prepare-branch"
  sh "mkdir #{package_dir}/lib/vendor/.bundle"
  sh "cp packaging/bundler-config #{package_dir}/lib/vendor/.bundle/config"

  # Hack to get paths containing spaces to behave correctly
  # @see https://github.com/phusion/traveling-ruby/issues/38
  sh %Q{sed -i '' -e 's|RUBYOPT=\\\\"-r$ROOT/lib/restore_environment\\\\"|RUBYOPT=\\\\"-rrestore_environment\\\\"|' #{package_dir}/lib/ruby/bin/ruby_environment}
  sh %Q{sed -i '' -e 's|GEM_HOME="$ROOT/lib/ruby/gems/2.2.0"|GEM_HOME=\\\\"$ROOT/lib/ruby/gems/2.2.0\\\\"|' #{package_dir}/lib/ruby/bin/ruby_environment}
  sh %Q{sed -i '' -e 's|GEM_PATH="$ROOT/lib/ruby/gems/2.2.0"|GEM_PATH=\\\\"$ROOT/lib/ruby/gems/2.2.0\\\\"|' #{package_dir}/lib/ruby/bin/ruby_environment}
  sh "mv #{package_dir}/lib/ruby/lib/restore_environment.rb #{package_dir}/lib/ruby/lib/ruby/2.2.0/restore_environment.rb"

  if !ENV['DIR_ONLY']
    sh "tar -czf dist/#{package_dir}.tar.gz #{package_dir}"
    sh "rm -rf #{package_dir}"
  end
end

def download_runtime(target)
  sh 'cd packaging && curl -L -O --fail ' +
    "https://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz"
end