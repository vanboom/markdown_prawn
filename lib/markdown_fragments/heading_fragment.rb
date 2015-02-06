class HeadingFragment < MarkdownFragment
  attr_accessor :level
  
    def render_on(pdf_object, options = {})
      arguments = _default_render_options.merge(options)
      pdf_object.move_down(@level)
      pdf_object.text @content.join(' '), arguments
      pdf_object.move_down(@level)
    end

  private

    def _default_render_options
      options = { :size => (40 - (8*@level)), :align => :left, :leading => 2, :weight => :bold, :color=>'444444' }
      options.merge({:inline_format => true})
      options
    end
end
