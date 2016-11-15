class TableFragment < MarkdownFragment
  HREF_Pattern = /
    \[(.*?)\]
    \((.*?)\)
  /x.freeze

  def render_on(pdf, options = {})
    arguments = _default_render_options.merge(options)
    headers = []
    rows = []
    # if the table has a header
    i = 0
    @content.each do |line|
      if line.join("").include?("---")
        headers << i-1
      else
        # sanitize out any hyperlinks
        line = line.map do |cell|
          matches = cell.scan(HREF_Pattern)
          matches.each do |m|
            cell.sub!(/\[#{m[0]}\]/, m[0])
            cell.sub!(/\(#{m[1]}\)/, "")
            cell = pdf.make_cell(:content=>"<color rgb='315f91'><link href='#{m[1]}'>#{m[0]}</link></color>", :inline_format=>true)
          end
          cell
        end
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
