class PreFragment < MarkdownFragment
  def render_on(pdf, options = {})
    arguments = _default_render_options.merge(options)
    arguments.merge!(size: pdf.font_size)
    c = @content.join("\n").gsub('```', '')
    code(pdf, [{:text=>c}])
#    pdf.move_down pdf.height_of("abc")
  end

  private

  def _default_render_options
    options = { :align => :left, :leading => 1 }
    options = options.merge({:inline_format => true})
    options
  end

end
