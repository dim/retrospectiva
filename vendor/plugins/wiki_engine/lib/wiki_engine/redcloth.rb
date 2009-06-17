module WikiEngine

  begin
    require 'rubygems'
    gem 'RedCloth', '>= 4.1.9'
    require 'RedCloth'
    RedCloth = ::RedCloth
  rescue LoadError
    require 'wiki_engine/redcloth_native/base'
    require 'wiki_engine/redcloth_native/textile'
    require 'wiki_engine/redcloth_native/markdown'
    require 'wiki_engine/redcloth_native/textile_doc'
    require 'wiki_engine/redcloth_native/formatters'
  end

end
