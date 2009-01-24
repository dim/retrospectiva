#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
module WikiHelper

  def wiki_navigation
    links = []

    links << link_to(_('Pages'), project_wiki_pages_path(Project.current))
    links << link_to(_('Files'), project_wiki_files_path(Project.current))
    
    if User.current.permitted?(:wiki_pages, :edit)
      links << if @wiki_page.historic?
        link_to _('Rollback'), edit_project_wiki_page_path(Project.current, @wiki_page, :version => @wiki_page.number)
      else
        link_to _('Edit'), edit_project_wiki_page_path(Project.current, @wiki_page)
      end
    end
    
    if User.current.permitted?(:wiki_pages, :rename)
      links << link_to(_('Rename'), rename_project_wiki_page_path(Project.current, @wiki_page))
    end
     
    if User.current.permitted?(:wiki_pages, :delete)
      links << link_to_wiki_page(_('Delete'), @wiki_page, 
        :confirm => _('Are you really sure?'),
        :method => :delete )
    end

    links.join(' | ')
  end
  
  def wiki_page_navigation
    links = []
    
    if @wiki_page.newer_versions > 0 
      links << link_to_wiki_page(_('Show current'), @wiki_page)
      links << link_to_wiki_page(_('Forward in time'), @wiki_page, :version => @wiki_page.number + 1) + note_after_link(_('{{count}} more', :count => @wiki_page.newer_versions)) 
    end
    
    if @wiki_page.older_versions > 0
      links << link_to_wiki_page(_('Back in time'), @wiki_page, :version => @wiki_page.number - 1) + note_after_link(_('{{count}} more', :count => @wiki_page.older_versions)) 
    end
    
    links.join(' | ')
  end

  private
    
    def note_after_link(content)
      " <span class=\"small\">(#{content})</span>"
    end
  
    def link_to_wiki_page(label, page, options = {})
      version = options.delete(:version)
      path = project_wiki_page_path Project.current, page, :version => version
      link_to(label, path, options)
    end

end
