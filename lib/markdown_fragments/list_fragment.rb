class ListFragment < MarkdownFragment
  attr_accessor :ordered
  BULLET = "\u2022".encode('utf-8').freeze
  def render_on(pdf, options = {})
    options = _default_render_options.merge(options)
    data = []
    j = 0
    @content.each_with_index do |item, i|
      # Strip any un-needed white space
      if item.is_a? Array
        # shrink embedded tables to avoid width constraints
        data << ["", pdf.make_table(item, _default_render_options.merge(column_widths: {0=>12}, width: pdf.bounds.width - 48))]
      else
        item = item.gsub(/\s\s+/,' ')
        if item == ""
          bullet = ""
        elsif ordered?
          j = j + 1
          bullet = "#{j}."
        else
          bullet = BULLET
        end
        data << [{content: bullet}, item.presence || "\n"]
      end
    end

    #    pdf.table data, arguments.merge({:width => width}) do
    #       cells.borders = []
    #       column(0).style( { :width => 20  })
    #    end
    #    pdf.move_down(5)
#    h = data.collect{|d| pdf.height_of(d[0] + " ")}.max
    # if ordered?
    #   w = data.collect{|d| d.is_a?(String) ? pdf.width_of(d[0] + " ") : 0}.max
    # else
    #   w = 7.5
    # end

    ##
    # New Way, use a table to render the list.
    pdf.pad(RHYTHM/2) do
      # improve control over the table width
      ox = options.merge(column_widths: {0=>12}, width: pdf.bounds.width - RHYTHM - 24)
      t = pdf.make_table data, ox
      t.draw
    end

  end

  def ordered?
    @ordered == true
  end

  private

  def _default_render_options
    options = {}
    options = options.merge( cell_style: { border_width: 0, align: :justify, padding: [0.5, 4, 0.5, 0]}, header: false )
    options
  end

end
