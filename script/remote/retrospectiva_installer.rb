#!/usr/bin/env ruby

require 'fileutils'
require 'uri'
require 'yaml'

class RemoteInstaller
  BRANCH = ARGV[0] || "2-0-stable"
  RETRO_URL    = "http://github.com/dim/retrospectiva/tarball/#{BRANCH}"
  RUBYGEMS_URL = "http://rubyforge.org/frs/download.php/60718/rubygems-1.3.5.tgz"
  RAKE_URL     = "http://rubyforge.org/frs/download.php/56872/rake-0.8.7.tgz"
  VENDOR_URL   = "http://cloud.github.com/downloads/dim/retrospectiva/vendor-#{BRANCH}.tar.gz"
  DOWNLOADERS  = [:curl, :wget]

  def self.run!
    new.run!
  end
    
  def initialize
    @rake       = false
    @rubygems   = false
  end

  def run!
    puts "\n  Retrospectiva Remote Installer\n  ==============================\n\n"

    check_prerequisites || instruct!
    detect_downloader
    install_retrospectiva!
    install_rubygems!
    install_rake!
    install_vendor!
    load_rake!
    build_gems!
    configure_db!
    create_database!

    next_steps!
  end

  protected

    def check_prerequisites
      check_lib('sqlite3')
    end
    
    def detect_downloader
      @downloader = DOWNLOADERS.detect do |m|
        system("#{m} --version 1> /dev/null 2> /dev/null", false)
      end || abort("[E] Unable to find #{DOWNLOADERS.join(' or ')} in your system path.")      
    end
    
    def check_lib(name)
      begin
        require_library_or_gem name
        true
      rescue LoadError        
        false
      end
    end

    def install_retrospectiva!
      unless File.exist?(ARCHIVE_PATH)
        step "Downloading Retrospectiva '#{BRANCH}' branch from '#{RETRO_URL}'"
        download! RETRO_URL, ARCHIVE_PATH
      end

      unless File.exist?(INSTALL_PATH)
        step "Unpacking Retrospectiva to '#{INSTALL_PATH}'", true
        unpack! ARCHIVE_PATH, ROOT_PATH
        temp_folder = Dir[File.join(ROOT_PATH, 'dim-retrospectiva-*')].first
        FileUtils.mv temp_folder, INSTALL_PATH
      end
    end

    def install_rubygems!
      if check_lib('rubygems')
        @rubygems = true
        return
      end
      
      unless File.exist?(RUBYGEMS_ARCHIVE)
        step "Downloading RubyGems from '#{RUBYGEMS_URL}'"
        download! RUBYGEMS_URL, RUBYGEMS_ARCHIVE
      end

      unless File.exist?(RUBYGEMS_PATH)
        step "Unpacking RubyGems to '#{RUBYGEMS_PATH}'", true
        unpack! RUBYGEMS_ARCHIVE, VENDOR_PATH
        temp_folder = Dir[File.join(VENDOR_PATH, 'rubygems-*')].first
        FileUtils.mv temp_folder, RUBYGEMS_PATH
      end
    end

    def install_rake!
      if check_lib('rake')
        @rake = true
        return
      end

      unless File.exist?(RAKE_ARCHIVE)
        step "Downloading Rake from '#{RAKE_URL}'"
        download! RAKE_URL, RAKE_ARCHIVE
      end

      unless File.exist?(RAKE_PATH)
        step "Unpacking Rake to '#{RAKE_PATH}'", true
        unpack! RAKE_ARCHIVE, VENDOR_PATH
        temp_folder = Dir[File.join(VENDOR_PATH, 'rake-*')].first
        FileUtils.mv temp_folder, RAKE_PATH
      end
    end

    def install_vendor!
      unless File.exist?(VENDOR_ARCHIVE)
        step "Downloading vendor libraries from '#{VENDOR_URL}'"
        download! VENDOR_URL, VENDOR_ARCHIVE
      end

      step "Unpacking vendor libraries to '#{VENDOR_PATH}'", true
      unpack! VENDOR_ARCHIVE, VENDOR_PATH
    end

    def configure_db!
      unless File.exists?(DATABASE_CONFIG)
        step "Writing database configuration"

        File.open(DATABASE_CONFIG, 'w+') do |file|
          file << "production:\n  adapter: sqlite3\n  database: db/production.db\n"
        end
      end
    end

    def create_database!
      unless File.exist?(DATABASE_FILE) and File.size(DATABASE_FILE) > 0
        step "Creating database", true
        silence_stream(STDOUT) do
          FileUtils.cp File.join(INSTALL_PATH, 'db', 'schema.core.rb'), File.join(INSTALL_PATH, 'db', 'schema.rb')
          Rake.application['db:setup'].invoke
        end
      end
    end

    def build_gems!
      step "Building GEMs", true
      silence_stream(STDOUT) do
        Rake.application['gems:build'].invoke
      end
    end

    def next_steps!      
      instructions = %Q(
        Next Steps:

        * Add the following line to your crontab (crontab -e):
           * *  * * *  RAILS_ENV=production #{ruby_path} #{INSTALL_PATH}/script/retro_tasks

        * Run Retrospectiva:
           cd retrospectiva; #{ruby_path} script/server -e production

        * Deploy as Apache2/NingX Virtual Host:
           Please visit http://www.modrails.com/ for more information
      )

      instructions << %Q(
        * Add Subversion support:
           #{subversion_howto}
      ) if subversion_howto

      instructions << %Q(
        * Add GIT support:
           #{git_howto}
      ) if git_howto

      instructions = instructions.split(/\n/).map do |line|
        line =~ /^\s+$/ ? line.strip : line.gsub(/^      /, '')
      end.join("\n")

      puts instructions + "\n"
    end

    def instruct!
      puts "  Support for SQLite3 is MISSING on your machine\n"

      if sqlite3_howto
        puts "  To install it, please call:\n\n"
        sqlite3_howto.each do |line|
          puts "    #{line}\n"
        end
        puts "\n  Re-run the installer afterwards\n\n"
      end
      
      exit(1)
    end

  private

    ROOT_PATH    = File.expand_path('./')
    ARCHIVE_PATH = File.join(ROOT_PATH, "retrospectiva-#{BRANCH}.tgz")
    INSTALL_PATH = File.join(ROOT_PATH, "retrospectiva")

    VENDOR_PATH = File.join(INSTALL_PATH, "vendor")
    RAKE_PATH = File.join(VENDOR_PATH, "rake")
    RUBYGEMS_PATH = File.join(VENDOR_PATH, "rubygems")

    RUBYGEMS_ARCHIVE = File.join(VENDOR_PATH, "rubygems.tgz")
    RAKE_ARCHIVE = File.join(VENDOR_PATH, "rake.tgz")
    VENDOR_ARCHIVE = File.join(VENDOR_PATH, "vendor.tgz")
    DATABASE_CONFIG = File.join(INSTALL_PATH, 'config', 'database.yml')
    DATABASE_FILE = File.join(INSTALL_PATH, 'db', 'production.db')

    def download!(url, path)
      case @downloader
      when :curl
        system "curl -s -L #{url} > #{path}"
      when :wget
        system "wget -q -O #{path} #{url}"
      end
    end

    def unpack!(file, path)
      system "tar xzf #{file} -C #{path}"
    end

    def step(description, nl = false)
      puts "  #{description}" + (nl ? "\n" : '')
    end

    def system(command, raise_on_error = true)
      super(command) || (raise_on_error && abort("[E] Command '#{command}' failed during execution"))
    end

    def ruby_path
      [
        ENV['_'],
        @rubygems ? nil : "-I#{File.join(RUBYGEMS_PATH, 'lib')}"
      ].compact.join(' ')
    end

    def load_rake!
      ENV['RAILS_ENV'] = 'production'
      $: << File.join(RAKE_PATH, 'lib') unless @rake
      $: << File.join(RUBYGEMS_PATH, 'lib') unless @rubygems
      load File.join(INSTALL_PATH, 'Rakefile')
    end

    def sqlite3_howto
      case platform
      when :debian
        ["sudo apt-get install libsqlite3-ruby sqlite3"]
      when :darwin
        ["sudo port install sqlite3 rb-rubygems", "sudo gem install sqlite3-ruby"]
      when :redhat
        [ "yum install ruby-devel sqlite sqlite-devel ruby-rdoc make gcc", "sudo gem install sqlite3-ruby" ]
      else
        nil
      end
    end

    def subversion_howto
      case platform
      when :debian
        "sudo apt-get install subversion libsvn-ruby"
      when :darwin
        "sudo port install subversion-rubybindings"
      when :redhat
        "sudo yum install subversion-ruby"
      else
        nil
      end
    end

    def git_howto
      case platform
      when :debian
        "sudo apt-get git-core"
      when :darwin
        "sudo port install git-core"
      when :redhat
        "sudo yum install git"
      else
        nil
      end
    end

    def platform
      @platform ||= if RUBY_PLATFORM =~ /win32/
        :windows
      elsif RUBY_PLATFORM =~ /linux/
        distribution
      elsif RUBY_PLATFORM =~ /darwin/
        :darwin
      elsif RUBY_PLATFORM =~ /freebsd/
        :freebsd
      else
        :unknown
      end
    end

    def distribution
      if File.exist?("/etc/debian_version")
        :debian
      elsif File.exist?("/etc/redhat-release")
        :redhat
      elsif File.exist?("/etc/suse-release")
        :suse
      elsif File.exist?("/etc/gentoo-release")
        :gentoo
      else
        :unknown
      end
    end

end

module Kernel

  def require_library_or_gem(library_name)
    begin
      require library_name
    rescue LoadError => cannot_require
      begin
        require 'rubygems'
      rescue LoadError
        raise cannot_require
      end
      begin
        require library_name
      rescue LoadError
        raise cannot_require
      end
    end
  end

  def silence_stream(stream)
    old_stream = stream.dup
    stream.reopen(RUBY_PLATFORM =~ /mswin/ ? 'NUL:' : '/dev/null')
    stream.sync = true
    yield
  ensure
    stream.reopen(old_stream)
  end

end

RemoteInstaller.run!
