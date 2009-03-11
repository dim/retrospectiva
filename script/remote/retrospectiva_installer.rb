#!/usr/bin/env ruby

require 'fileutils'
require 'uri'
require 'yaml'

class RemoteInstaller
  BRANCH = ARGV[0] || "master"
  URL = "http://github.com/dim/retrospectiva/tarball/#{BRANCH}"
  RUBYGEMS_URL = "http://rubyforge.org/frs/download.php/45905/rubygems-1.3.1.tgz"
  RAKE_URL = "http://rubyforge.org/frs/download.php/43955/rake-0.8.3.tgz"
  RAILS_URL = lambda { |rails_version| "http://github.com/rails/rails/tarball/v#{rails_version}.tgz" }

  def self.run!
    new.run!
  end

  def run!
    puts "\n  Retrospectiva Remote Installer\n  ==============================\n\n"

    check_prerequisites || exit(1)
    install_retrospectiva!
    install_rake!
    install_rails!
    install_gems!
    load_rake!
    configure_db!
    create_database!

    next_steps!
  end

  protected

    def check_prerequisites
      begin
        require_library_or_gem 'sqlite3'
        true
      rescue LoadError
        sqlite3_instruct!
        false
      end
    end

    def install_retrospectiva!
      unless File.exist?(ARCHIVE_PATH)
        step "Downloading Retrospectiva '#{BRANCH}' branch from '#{URL}'"
        download! URL, ARCHIVE_PATH
      end

      unless File.exist?(INSTALL_PATH)
        step "Unpacking Retrospectiva to '#{INSTALL_PATH}'"
        unpack! ARCHIVE_PATH, ROOT_PATH
        temp_folder = Dir[File.join(ROOT_PATH, 'dim-retrospectiva-*')].first
        FileUtils.mv temp_folder, INSTALL_PATH
      end
    end

    def install_rails!
      unless File.exist?(RAILS_ARCHIVE)
        step "Downloading Rails v#{rails_version} from '#{RAILS_URL.call(rails_version)}'"
        download! RAILS_URL.call(rails_version), RAILS_ARCHIVE
      end

      unless File.exist?(RAILS_PATH)
        step "Unpacking Rails to '#{RAILS_PATH}'"
        unpack! RAILS_ARCHIVE, VENDOR_PATH
        temp_folder = Dir[File.join(VENDOR_PATH, 'rails-rails-*')].first
        FileUtils.mv temp_folder, RAILS_PATH
      end
    end

    def install_rake!
      unless File.exist?(RAKE_ARCHIVE)
        step "Downloading Rake from '#{RAKE_URL}'"
        download! RAKE_URL, RAKE_ARCHIVE
      end

      unless File.exist?(RAKE_PATH)
        step "Unpacking Rake to '#{RAKE_PATH}'"
        unpack! RAKE_ARCHIVE, VENDOR_PATH
        temp_folder = Dir[File.join(VENDOR_PATH, 'rake-*')].first
        FileUtils.mv temp_folder, RAKE_PATH
      end
    end

    def install_gems!
      required_gems.each do |name, source|
        unless File.exist?(gem_archive_path(name))
          gem_url = source + "/gems/#{name}.gem"
          step "Downloading GEM #{name} from '#{source}'"
          download! gem_url, gem_archive_path(name)
        end

        unless File.exist?(gem_path(name))
          FileUtils.mkdir_p(gem_path(name))
          step "Unpacking GEM #{name}"
          system "tar xf #{gem_archive_path(name)} --exclude metadata.gz -O | tar xz -C #{gem_path(name)} 2> /dev/null"
          system "tar xf #{gem_archive_path(name)} --exclude data.tar.gz -O | gzip -d > #{File.join(gem_path(name), '.specification')} 2> /dev/null"
        end
      end
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
        step "Creating database content"
        silence_stream(STDOUT) do
          Rake.application['db:retro:load'].invoke
        end
      end
    end

    def next_steps!
      instructions = %Q(
        Next Steps:

        * Add the following line to your crontab (crontab -e):
           * *  * * *  RAILS_ENV=production ruby #{INSTALL_PATH}/script/retro_tasks

        * Run Retrospectiva (not recommended for production):
           cd retrospectiva; ruby script/server -e production

        * Deploy as Apache2 Virtual Host:
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

    def sqlite3_instruct!
      puts "  Support for SQLite3 is MISSING on your machine\n"

      if sqlite3_howto
        puts "  To install it, please call:\n\n"
        sqlite3_howto.each do |line|
          puts "    #{line}\n"
        end
        puts "\n  Re-run the installer afterwards\n\n"
      end
    end

  private

    ROOT_PATH    = File.expand_path('./')
    ARCHIVE_PATH = File.join(ROOT_PATH, "retrospectiva-#{BRANCH}.tgz")
    INSTALL_PATH = File.join(ROOT_PATH, "retrospectiva")

    VENDOR_PATH = File.join(INSTALL_PATH, "vendor")
    RUBYGEMS_PATH = File.join(VENDOR_PATH, "rubygems")
    RAILS_PATH = File.join(VENDOR_PATH, "rails")
    RAKE_PATH = File.join(VENDOR_PATH, "rake")
    GEMS_PATH = File.join(VENDOR_PATH, "gems")

    RUBYGEMS_ARCHIVE = File.join(VENDOR_PATH, "rubygems.tgz")
    RAILS_ARCHIVE = File.join(VENDOR_PATH, "rails.tgz")
    RAKE_ARCHIVE = File.join(VENDOR_PATH, "rake.tgz")
    DATABASE_CONFIG = File.join(INSTALL_PATH, 'config', 'database.yml')
    DATABASE_FILE = File.join(INSTALL_PATH, 'db', 'production.db')

    def required_gems
      @required_gems ||= GemsConfig.new(environment.scan(/config\.gem .+$/))
    end

    def download!(url, path)
      system "wget -q -O #{path} #{url}"
    end

    def unpack!(file, path)
      system "tar xzf #{file} -C #{path}"
    end

    def gem_path(name)
      File.join(GEMS_PATH, name)
    end

    def gem_archive_path(file_name)
      File.join(VENDOR_PATH, file_name + '.gem')
    end

    def rails_version
      @rails_version ||= environment.match(/RAILS_GEM_VERSION\D+([\d\.]+)/)[1]
    end

    def environment
      @environment ||= File.read(File.join(INSTALL_PATH, 'config', 'environment.rb'))
    end

    def step(description)
      puts "  #{description}"
    end

    def system(command)
      super(command) || abort("[E] Command '#{command}' failed during execution")
    end

    def load_rake!
      ENV['RAILS_ENV'] = 'production'
      lib_path = File.join(RAKE_PATH, 'lib')
      $: << lib_path
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

    class GemsConfig < Hash

      def initialize(lines)
        super()
        lines.each do |line|
          eval line.gsub(/^\s*config\./, '')
        end
      end

      def gem(name, options = {})
        name = name + '-' + options[:version].gsub(/[^\d.]/, '')
        self[name] = options[:source] || 'http://gems.rubyforge.org'
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
