class ParagraphFragment < MarkdownFragment
  def render_on(pdf_object, options = {})
    arguments = _default_render_options.merge(options)
    pdf_object.pad(RHYTHM/2) do
      pdf_object.formatted_text formatted_content, arguments
    end
  end

  private

  def _default_render_options
    options = { :align => :left, :leading => 0 }
    options = options.merge({:inline_format => true})
    options
  end

end
