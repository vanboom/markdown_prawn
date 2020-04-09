class HeadingFragment < MarkdownFragment
  attr_accessor :level

    def render_on(pdf_object, options = {})
      arguments = _default_render_options.merge(options)
      arguments.merge!( size: pdf_object.font_size + (2*@level))
      pdf_object.move_down 12
      pdf_object.formatted_text formatted_content, arguments
    end

  private

    def _default_render_options
      options = { :align => :left, :leading => 4, :weight => :bold, :color=>'444444' }
      options.merge({:inline_format => true})
      options
    end
end
