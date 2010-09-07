#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
module WikiHelper

  def wiki_navigation
    links = []

    links << link_to(_('Home'), project_wiki_page_path(Project.current, Project.current.wiki_title))
    links << link_to(_('Pages'), project_wiki_pages_path(Project.current))
    links << link_to(_('Files'), project_wiki_files_path(Project.current))
    
    if permitted?(:wiki_pages, :update)
      links << if @wiki_page.historic?
        link_to _('Rollback'), edit_project_wiki_page_path(Project.current, @wiki_page, :version => @wiki_page.number)
      else
        link_to _('Edit'), edit_project_wiki_page_path(Project.current, @wiki_page)
      end
    end
    
    if permitted?(:wiki_pages, :rename)
      links << link_to(_('Rename'), rename_project_wiki_page_path(Project.current, @wiki_page))
    end
     
    if permitted?(:wiki_pages, :delete)
      links << link_to_wiki_page(_('Delete'), @wiki_page, options_for_destroy_link)
    end

    links.join(' | ')
  end
  
  def wiki_page_navigation
    links = []
    
    if @wiki_page.newer_versions > 0 
      links << link_to_wiki_page(_('Show current'), @wiki_page)
      links << link_to_wiki_page(_('Forward in time'), @wiki_page, :version => @wiki_page.number + 1) + note_after_link(_('%{count} more', :count => @wiki_page.newer_versions)) 
    end
    
    if @wiki_page.older_versions > 0
      links << link_to_wiki_page(_('Back in time'), @wiki_page, :version => @wiki_page.number - 1) + note_after_link(_('%{count} more', :count => @wiki_page.older_versions)) 
    end
    
    links.join(' | ')
  end
  
  def anchorize(html)
    html.gsub(/(\<h1[^>]*\>)(.+?)\<\/h1\>/ui) do |match|
      tag, text = $1, $2
      anchor = ActiveSupport::Inflector.transliterate(strip_tags(text))
      anchor.gsub!(/\&\w+\;/, '')
      anchor.gsub!(/\W/, '-')
      anchor.squeeze!('-')
      anchor.gsub!(/-$/i, '')
      "#{tag}#{text} <a id=\"#{anchor}\" href=\"##{anchor}\" class=\"wiki-anchor\">&para;</a></h1>"
    end
  end

  def include_wiki_stylesheet
    content_for :header do
      x_stylesheet_link_tag('retro_wiki')      
    end
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
