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
        data << ["", pdf.make_table(item, _default_render_options)]
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
        data << [bullet,item.presence || "\n"]
      end
    end

    #    pdf.table data, arguments.merge({:width => width}) do
    #       cells.borders = []
    #       column(0).style( { :width => 20  })
    #    end
    #    pdf.move_down(5)
#    h = data.collect{|d| pdf.height_of(d[0] + " ")}.max
    if ordered?
      w = data.collect{|d| d.is_a?(String) ? pdf.width_of(d[0] + " ") : 0}.max
    else
      w = 7.5
    end

    ##
    # New Way, use a table to render the list.
    pdf.pad(RHYTHM/2) do
      t = pdf.make_table data, options
      t.draw
    end

  end

  def ordered?
    @ordered == true
  end

  private

  def _default_render_options
    options = {}
    options = options.merge( cell_style: {borders: [], align: :justify, padding: [0.5, 4, 0.5, 0]}, header: true )
    options
  end

end
