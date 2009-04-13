#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
RetroAM.permission_map do |map|

  map.resource :wiki_pages, :label => N_('Wiki Pages') do |pages|
    pages.permission :view,   :label => N_('View')
    pages.permission :update, :label => N_('Update')
    pages.permission :rename, :label => N_('Rename')
    pages.permission :delete, :label => N_('Delete')
  end
  map.resource :wiki_files, :label => N_('Wiki Files') do |files|
    files.permission :create, :label => N_('Create')
    files.permission :delete, :label => N_('Delete')    
  end

end

require 'wiki_engine_extensions'