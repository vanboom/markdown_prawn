class HeadingFragment < MarkdownFragment
  attr_accessor :level

    def render_on(pdf_object, options = {})
      arguments = _default_render_options.merge(options)
      pdf_object.text @content.join(' '), arguments
    end

  private

    def _default_render_options
      options = { :size => (24 - (4*@level)), :align => :left, :leading => 2, :weight => :bold, :color=>'444444' }
      options.merge({:inline_format => true})
      options
    end
end
