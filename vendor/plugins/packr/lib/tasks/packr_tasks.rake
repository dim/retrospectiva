require RAILS_ROOT + '/vendor/plugins/packr/init'

namespace :packr do
  desc "Takes all scripts from lib/javascripts and writes packed copies to public/javascripts"
  task :pack_libs do
    dir = "#{RAILS_ROOT}/lib/javascripts"
    if File.directory?(dir)
      scripts = Dir.entries(dir).find_all { |path| path =~ /\.js/ }
      packer = Packr.new
      scripts.each do |script|
        code = File.read("#{dir}/#{script}")
        packed = packer.pack(code, :base62 => !!ENV['base62'], :shrink_vars => !!ENV['shrink_vars'])
        target = "#{RAILS_ROOT}/public/javascripts/#{script.gsub(/\.(src|source)\.js$/i, '.js')}"
        File.open(target, "wb") { |f| f.write packed }
        puts "\n  Packed #{script}: #{File.size("#{dir}/#{script}")} --> #{File.size(target)}"
      end
    end
  end
end
