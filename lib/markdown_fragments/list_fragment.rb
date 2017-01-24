class ListFragment < MarkdownFragment
  attr_accessor :ordered

  def render_on(pdf, options = {})
    bullet = '•'
    bullet = "\u2022".encode('utf-8')
    arguments = _default_render_options.merge(options)
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
    h = data.collect{|d| pdf.height_of(d[0] + " ")}.max

    if ordered?
      w = data.collect{|d| pdf.width_of(d[0] + " ")}.max
    else
      w = 7.5
    end

    data.each do |row|
      itemheight = pdf.height_of_formatted(format_line(row[0] + "  " + row[1]))
      # orphan control, start a new page if the dry run returns unprinted text
      dr = Prawn::Text::Formatted::Box.new(format_line(row[1]), :at=>[w, pdf.cursor+h], :document=>pdf)
      result = dr.render(:dry_run=>true)
      if result.count > 0
        pdf.start_new_page
      end
      pdf.formatted_text(format_line(row[0] + " "))
      pdf.formatted_text_box(format_line(row[1]), :at=>[w, pdf.cursor+h])
      pdf.move_down(itemheight - h)
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
