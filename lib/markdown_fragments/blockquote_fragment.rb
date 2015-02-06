class BlockquoteFragment < MarkdownFragment

  def render_on(pdf, options = {})
    arguments = _default_render_options.merge(options)

    blockquote_box(pdf, formatted_content)
  end

private

  def _default_render_options
    options = { :size => 12, :align => :left, :leading => 0, :style=>:italic, :color=>'555555' }
    options = options.merge({:inline_format => true})
    options
  end

end
