class TaskFragment < MarkdownFragment
  attr_accessor :level

    def render_on(pdf, options = {})
      arguments = _default_render_options.merge(options)
      pdf.formatted_text formatted_content, arguments
    end

  private
    def task_complete?
      @content.join.match /^- \[x\]/
    end

    def strip_markup!
      @content = @content.map{|l| l.gsub(/^- \[.\]/,"")}
    end

    def _default_render_options
      options = { :align => :left, :leading => 0 }
      options = options.merge({:inline_format => true})
      options
    end

    # CANT GET THIS TO WORK PROPERLY
    def checkbox(pdf, flag, x, y)
      pdf.bounding_box([x, y], width: 12, height: 12) do
        pdf.stroke_bounds
        pdf.text("X", align: :center, valign: :center) if flag
      end
    end
end
