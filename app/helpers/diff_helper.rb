module DiffHelper

  def format_diff(unified_diff, path)
    scanner = Project.current.repository.diff_scanner.new(unified_diff)
    tbody_tags = scanner.blocks.map do |block|
      block.line_pairs.map do |line_set|
        table_rows = []
        line_set.each_with_index do |(source, target), i|
          table_rows << content_tag(:tr,
            wrap_diff(:th, source.n1) + wrap_diff(:td, source) +
            wrap_diff(:th, target.n1) + wrap_diff(:td, target),
            :class => html_class_for_diff_row(i, line_set.size)
          )
        end
        "<tbody class=\"#{line_set.operation}\">#{table_rows.join("\n")}</tbody>"
      end.join("\n")      
    end
    
    content_tag :table, 
      colgroup_for_diff_table +
      header_for_diff_table(scanner, path) +      
      body_for_diff_table(tbody_tags),
      :class => 'code code-split'
  end

  protected

    def header_for_diff_table(scanner, path)
      source_rev = link_to_browse h(truncate_revision(scanner.source_rev)), path, scanner.source_rev
      target_rev = link_to_browse h(truncate_revision(scanner.target_rev)), path, scanner.target_rev
      "<thead><tr><th colspan=\"2\">#{source_rev}</th><th colspan=\"2\">#{target_rev}</th></tr></thead>"      
    end
    
    def colgroup_for_diff_table
      '<colgroup><col class="code-line"/><col class="code-left"/><col class="code-line"/><col class="code-right"/></colgroup>'
    end
    
    def body_for_diff_table(tbody_tags)
      separator = content_tag :tr,
        wrap_diff(:th, '...') + wrap_diff(:td, nil) +
        wrap_diff(:th, '...') + wrap_diff(:td, nil),
        :class => 'separator'
      tbody_tags.join("<tbody>#{separator}</tbody>")
    end

    def html_class_for_diff_row(index, row_count)
      c = [index.zero? ? 'first' : nil] + [index == row_count - 1 ? 'last' : nil]
      c.compact.blank? ? nil : c.compact.join(' ')
    end

    def wrap_diff(tag, values, options = {}, joiner = "\n")
      values = values.join(joiner) if values.is_a?(Array)
      content_tag tag, "<pre>#{values ? h(values) : '&nbsp;'}</pre>", options
    end

    def truncate_revision(revision)
      Project.current.repository ? Project.current.repository.class.truncate_revision(revision) : revision      
    end

end
