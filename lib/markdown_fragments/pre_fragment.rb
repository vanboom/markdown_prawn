class PreFragment < MarkdownFragment
  def render_on(pdf, options = {})
    arguments = _default_render_options.merge(options)
    c = @content.join("\n").gsub('```', '')
    code(pdf, [{:text=>c}])
#    pdf.move_down pdf.height_of("abc")
  end

  private

  def _default_render_options
    options = { :size => 12, :align => :left, :leading => 1 }
    options = options.merge({:inline_format => true})
    options
  end

end
