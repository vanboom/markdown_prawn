class MarkdownFragment
  attr_accessor :content
  INNER_MARGIN = 30
  RHYTHM = 6
  LEADING = 2
  @@formats = [
                {:r=>/\*{2}(.*)\*{2}/, :format=>{:styles=>[:bold]}},
                {:r=>/__\*([\w\s`]*)\*__/, :format=>{:styles=>[:bold, :italic]}},
                {:r=>/\*([^\*]*)\*/, :format=>{:styles=>[:italic]}},
                {:r=>/`([^`]*)`/, :format=>{:font=>"Courier"}}, # inline monospace
                {:r=>/(\[(.+?)\]\((.+?)\))/, :format=>:hyperlink}   # hyperlinks
              ]

  # Colors
  #
  BLACK      = "000000"
  LIGHT_GRAY = "eeeeee"
  GRAY       = "DDDDDD"
  DARK_GRAY  = "333333"
  BROWN      = "A4441C"
  ORANGE     = "F28157"
  LIGHT_GOLD = "FBFBBE"
  DARK_GOLD  = "EBE389"
  BLUE       = "0000D0"
  def initialize(content = [])
    @content = content
  end

  # Renders the current fragment on the supplied prawn PDF Object. By Default,
  # it will just join content and add it as text - not too useful.
  def render_on(pdf_object)
    pdf_object.text @content.join(' ')
  end

  def inner_box(pdf_object, &block)
    bounding_box([INNER_MARGIN, pdf_object.cursor],
                     :width => pdf_object.bounds.width - INNER_MARGIN*2,
                     &block)
  end

  # provide pre_text as if you were doing a formatted_text
  def code(pdf, pre_text)
    #pre_text = ::CodeRay.scan(pre_text, :ruby).to_prawn
    pdf.font('Courier') do
      #colored_box(pdf, pre_text)
      pdf.indent(4) do
        pdf.formatted_text(pre_text)
      end
    end
  end

  # Renders a Bounding Box with some background color and the formatted text
  # inside it
  # This stinks = we need a better way to do shaded boxes!
  def colored_box(pdf, box_text, options={})
    options = { :fill_color   => LIGHT_GRAY,
      :stroke_color => nil,
      :text_color   => DARK_GRAY,
      :leading      => LEADING
    }.merge(options)

    text_options = { :leading        => options[:leading],
      :fallback_fonts => ["DejaVu", "Kai"], :color=>options[:text_color]
    }
    f = pdf.fill_color
    s = pdf.stroke_color

    box_height = pdf.height_of_formatted(box_text, text_options)

    # if the cursor is near the bottom of the page
    # yet another Prawn formatting pos
    if pdf.cursor < box_height*2
      pdf.start_new_page
    end
    pdf.bounding_box([INNER_MARGIN + RHYTHM, pdf.cursor],
    :width => pdf.bounds.width - (INNER_MARGIN+RHYTHM)*2) do

      pdf.fill_color   options[:fill_color]
      pdf.stroke_color options[:stroke_color] || options[:fill_color]
      pdf.fill_and_stroke_rounded_rectangle(
      [pdf.bounds.left - RHYTHM, pdf.cursor],
      pdf.bounds.left + pdf.bounds.right + RHYTHM*2,
      box_height + RHYTHM*2,
      0
      )
      pdf.fill_color   LIGHT_GRAY
      pdf.stroke_color DARK_GRAY

      pdf.pad(RHYTHM) do
        pdf.formatted_text(box_text, text_options)
      end
    end
    pdf.move_down(RHYTHM*2)
    pdf.fill_color = f
    pdf.stroke_color = s
  end


  # Renders a Bounding Box with some background color and the formatted text
  # inside it
  #
  def blockquote_box(pdf, box_text, options={})
    options = { :fill_color   => LIGHT_GRAY,
      :stroke_color => nil,
      :text_color   => '666666',
      :leading      => LEADING
    }.merge(options)

    text_options = { :leading        => options[:leading],
      :fallback_fonts => ["DejaVu", "Kai"], :color=>options[:text_color]
    }
    f = pdf.fill_color
    s = pdf.stroke_color

    box_height = 0
    pdf.bounding_box([RHYTHM, pdf.cursor], :width=>pdf.bounds.width-(RHYTHM*2)) do
      box_height = pdf.height_of_formatted(box_text, text_options)
    end
    # if the cursor is near the bottom of the page
    # yet another Prawn formatting pos
    if pdf.cursor < box_height + RHYTHM
      pdf.start_new_page
    end
    pdf.move_down RHYTHM/2
    pdf.bounding_box([RHYTHM, pdf.cursor],
    :width => pdf.bounds.width - (RHYTHM*2)) do

      pdf.fill_color   options[:fill_color]
      pdf.stroke_color options[:stroke_color] || options[:fill_color]
      # the blockquotes look better with a left margin line and a grey text
      # pdf.fill_and_stroke_rounded_rectangle(
      #   [pdf.bounds.left - RHYTHM, pdf.cursor],
      #   pdf.bounds.left + pdf.bounds.right + RHYTHM*2,
      #   box_height + RHYTHM,
      #   0
      # )
      pdf.fill_color   LIGHT_GRAY
      pdf.stroke_color GRAY
      pdf.stroke_line [pdf.bounds.left - RHYTHM, pdf.cursor], [pdf.bounds.left-RHYTHM, -box_height-RHYTHM]
      pdf.pad(RHYTHM) do
        pdf.formatted_text(box_text, text_options)
      end
    end
    pdf.move_down(RHYTHM/2)
    pdf.fill_color = f
    pdf.stroke_color = s
  end

  def formatted_content
    return @content.map{ |line| format_line(line)}.flatten
  end

  def format_line(line)
    formatted = [{:text=>line}]
    i = 0
    # for each line in the content
    while i < formatted.count do
      line = formatted[i][:text]
      s = StringScanner.new(line)
      j = i
      i = i + 1
      # find the first match of any of the formats
      @@formats.each do |f|
        s.scan_until f[:r]
        if not s.matched_size.nil?
          case f[:format]
          when :hyperlink
            formatted[j] = [{:text=>s.pre_match}, {:text=>s[2], :color=>'315f91', :link=>s[3]}, {:text=>s.post_match}]
          else
            formatted[j] = [{:text=>s.pre_match}, {:text=>s[1]}.merge(f[:format]), {:text=>s.post_match}]
          end
          formatted.flatten!
          # rescan from the top
          i = 0
          break
        end
      end
    end
    formatted
  end
end
