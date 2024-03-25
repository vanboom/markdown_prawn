class HeadingFragment < MarkdownFragment
  attr_accessor :level
    ##
    # Heading 4 size should be the same text size
    # Then we go up 2 steps from there
    def render_on(pdf_object, options = {})
      arguments = _default_render_options.merge(options)
      h4_size = pdf_object.font_size
      arguments.merge!( size: [h4_size, h4_size + (2 * (4 - @level))].max)
      pdf_object.move_down 4
      pdf_object.formatted_text formatted_content, arguments
    end

  private

    def _default_render_options
      options = { :align => :left, :leading => 4, :weight => :bold, :color=>'444444' }
      options.merge({:inline_format => true})
      options
    end
end
