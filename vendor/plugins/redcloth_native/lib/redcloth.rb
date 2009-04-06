begin
  require 'rubygems'
  require 'RedCloth'
rescue LoadError
  require 'redcloth_native/base'
  require 'redcloth_native/textile'
  require 'redcloth_native/markdown'
  require 'redcloth_native/textile_doc'
  require 'redcloth_native/formatters'
end