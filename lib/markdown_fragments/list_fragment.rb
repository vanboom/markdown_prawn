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
    w = data.collect{|d| pdf.width_of(d[0])}.max
    h = data.collect{|d| pdf.height_of(d[0])}.max
    data.each do |row|
      # start a new page if this list element will not fit on the given page
      if pdf.cursor - pdf.height_of_formatted(format_line(row[0] + "    " + row[1]))-h < 0
        pdf.start_new_page
      end
      pdf.formatted_text(format_line(row[0]))
      pdf.formatted_text_box(format_line(row[1]), :at=>[w, pdf.cursor+h])
      pdf.move_down pdf.height_of_formatted(format_line(row[0] + "    " + row[1]))-h
    end
#    pdf.move_down pdf.height_of_formatted(format_line(data.last[1]))
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
