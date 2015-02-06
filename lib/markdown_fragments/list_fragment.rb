class ListFragment < MarkdownFragment
  attr_accessor :ordered
  def render_on(pdf, options = {})
    bullet = '• '
    arguments = _default_render_options.merge(options)
    width = ((pdf.bounds.width / 100) * 90)
    data = []

    @content.each_with_index do |item, i|
    # Strip any un-needed white space
    #
      item = item.gsub(/\s\s+/,' ')
      if ordered?
        bullet = "#{i+1}."
      end
      data << [bullet,item]
    end

    #    pdf.table data, arguments.merge({:width => width}) do
    #       cells.borders = []
    #       column(0).style( { :width => 20  })
    #    end
    #    pdf.move_down(5)
    w = data.collect{|d| pdf.width_of(d[0]) + 4}.max
    data.each do |row|
      pdf.float do
        pdf.span(w, :position=>:left) do
          pdf.formatted_text(format_line(row[0]))
        end
      end
      pdf.span(pdf.bounds.width-w-4, :position=>:right) do
        pdf.formatted_text(format_line(row[1]))
      end
    end
  end

  def ordered?
    @ordered == true
  end

  private

  def _default_render_options
    options = {}
    options = options.merge({:cell_style => {:padding=>[0, 0, 0, 0], :inline_format => true}})
    options
  end

end
