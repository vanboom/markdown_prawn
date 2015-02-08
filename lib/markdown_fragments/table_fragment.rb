class TableFragment < MarkdownFragment
  def render_on(pdf, options = {})
    arguments = _default_render_options.merge(options)
    headers = []
    rows = []
    # if the table has a header
    i = 0
    puts "DOING TABLE FRAGMENT"
    @content.each do |line|
      puts line.inspect
      if line.join("").include?("---")
        headers << i-1
      else
        rows << line
        i = i + 1
      end        
    end

    pdf.table rows, arguments do
      headers.each do |i|
        row(i).font_style = :bold
      end
    end
  end

  private

  def _default_render_options
    options = { :row_colors=>["dfdfdf","efefef"], :cell_style=>{:border_color=>"cdcdcd", :inline_format=>true}}
    options
  end

end
