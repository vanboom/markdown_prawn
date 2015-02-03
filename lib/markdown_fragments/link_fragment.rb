class LinkFragment < MarkdownFragment

  def render_on(pdf_object, options = {})
    arguments = _default_render_options.merge(options)
#    pdf_object.text "<a href='%s'>%s</a>" % [@content[1], @content[0]], arguments
    pdf_object.formatted_text [{:text=>@content[0], :link=>@content[1]}.merge(options)]
  end

private

  def _default_render_options
    options = { :size => 12, :align => :left, :leading => 2 }
    options = options.merge({:inline_format => true})
    options
  end

end
