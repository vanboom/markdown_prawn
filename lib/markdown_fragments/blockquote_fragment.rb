class BlockquoteFragment < MarkdownFragment

  def render_on(pdf, options = {})
    arguments = _default_render_options.merge(options)
    pdf.pad(8) do
      pdf.bounding_box([32, pdf.cursor], :width=>pdf.bounds.width-32 ) do
        box_height = pdf.height_of(@content.join(' '))
        f = pdf.fill_color
        s = pdf.stroke_color
        lw = pdf.line_width
        
        pdf.fill_color 'eeeeee'
        pdf.stroke_color 'cdcdcd'
        pdf.line_width 4
        pdf.fill_rectangle([pdf.bounds.left, pdf.cursor+8], pdf.bounds.width-72, box_height+16)
        pdf.stroke_line [pdf.bounds.left, pdf.cursor+8], [pdf.bounds.left, -box_height-8]
        pdf.fill_color f
        pdf.stroke_color s
        pdf.line_width lw
        pdf.formatted_text_box [{:text=>@content.join(' ')}.merge(arguments)], :at=>[8,0], :width=>pdf.bounds.width-88
        pdf.move_down 16
      end
    end
  end

private

  def _default_render_options
    options = { :size => 12, :align => :left, :leading => 2, :style=>:italic, :color=>'555555' }
    options = options.merge({:inline_format => true})
    options
  end

end
