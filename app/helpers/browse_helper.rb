module BrowseHelper
  include DiffHelper
  include RepositoriesHelper

  def browseable_path(last_element_clickable = true)
    joined_path = []
    path_links = params[:path].map do |token|
      joined_path << token.dup
      if params[:path].last == token && !last_element_clickable
        token
      else
        link_to_browse token, joined_path, params[:rev]
      end
    end

    path_links.unshift link_to_browse('root', [], params[:rev])
    content_tag('h2', path_links.join('/'), :class => 'browseable-path')
  end
  
  def format_properties(property_hash) 
    property_hash.keys.sort_by(&:to_s).map do |name|
      "<em class=\"loud\">#{h(name)}</em>: #{h(property_hash[name])}"
    end.join(', ') 
  end

  def format_code_with_line_numbers(node)
    content = syntax_highlight(node)   
    content.force_encoding('utf-8') if RUBY_VERSION.to_f >= 1.9

    lines, code = [], []
      
    num = 0
    content.each_line do |line|
      lines << link_to_code_line(num += 1)
      code << line.gsub(/\r?\n/, '')
    end
    content_tag :table, %Q(
      <colgroup><col class="code-line"/><col class="code-full"/></colgroup>
      <tbody>
        <tr>
          <th><pre>#{lines.join("\n")}</pre></th>
          <td><pre>#{code.join("\n")}</pre></td>
        </tr>
      </tbody>
    ), :class => 'code'      
  end

  def link_to_diff(label, current_node, path_tokens, revision)
    if current_node.dir? || current_node.binary?
      '&nbsp;'
    elsif revision == current_node.revision
      "<em>#{_('Current')}</em>"
    else
      link_to label, 
        project_diff_path(Project.current, path_tokens, :rev => current_node.revision, :compare_with => revision),
        :title => _('Compare [%{revision_a}] with [%{revision_b}]', :revision_a => current_node.revision, :revision_b => revision)      
    end    
  end
  
  def link_to_revisions
    link_to _('Revisions'), project_revisions_path(Project.current, params[:path], :rev => params[:rev])
  end

  def node_download_links(*formats)
    [formats].flatten.uniq.map do |format|
      label, path = case format
      when :raw
        [ _('Raw'), project_download_path(Project.current, params[:path], :rev => params[:rev]) ]
      when :text
        [ _('Text'), project_browse_path(Project.current, params[:path], :rev => params[:rev], :format => 'text') ]
      end
      label && path ? link_to(label, path) : nil
    end.compact.join(' | ')
  end
  
  protected

    def link_to_code_line(line_number)
      anchor = "ln#{line_number}"
      link_to line_number.to_s,
        project_browse_path(Project.current, params[:path], :rev => @node.selected_revision, :anchor => anchor),
        :title => _('Line %{number}', :number => line_number),
        :class => 'block', :id => anchor
    end

    def syntax_highlight(node)
      syntax  = CodeRay::FileType.fetch node.path, :plaintext, false
      CodeRay.scan(node.content, syntax).html
    end
  
end
