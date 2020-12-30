require File.dirname(__FILE__) + '/../markdown_fragments.rb'

module MarkdownPrawn
  RX_NUM_LIST = /^\s?\*\s/.freeze
  RX_BUL_LIST = /^\s?\d+\.\s/.freeze
  RX_SUB_NUM_LIST = /^\s*\*\s/.freeze
  RX_SUB_BUL_LIST = /^\s*\d+\.\s/.freeze

  # Horribly bodgy and wrong markdown parser which should just about do
  # for a proof of concept. Some of the code comes from mislav's original
  # BlueCloth since I cant find the source of a newer versoin.
  #
  class Parser
    attr_accessor :links_list, :images_list, :document_structure
    def initialize(document_structure = [])
      @links_list = { :urls_seen => [], :object => LinksReferenceFragment.new }
      @document_structure = []
      @images_list = []
    end

    # Returns a Prawn::Document, accepts the same options as Prawn does when creating
    # a new document, but defaults to creating pages in Portrait and at A4 size.
    #
    # Uses parse! rather than parse to ensure that the slate is always clean when
    # generating the PDF.
    #
    def to_pdf(options = {})
      parse!
      options = { :page_layout =>  :portrait, :page_size => 'LETTER' }.merge(options)
      pdf = Prawn::Document.new(options)
      @document_structure.each { |markdown_fragment| markdown_fragment.render_on(pdf) }
      pdf
    end

    # Clears out the current sate of +@document_structure+ and then parses +@content+ content
    #
    def parse!
      @document_structure = []
      parse
    end

    def parse
      paragraph = ParagraphFragment.new
      list = ListFragment.new
      in_list = false
      @content.each_with_index do |line, index|
      #        line = process_inline_formatting(line)
      #        line = process_inline_hyperlinks(line)

      # Assume everything is part of a paragraph by default and
      # add its content to the current in-scope paragraph object.
      #
        unless (paragraph.instance_of?(TableFragment) or line.empty?)
          paragraph.content << line
        end

        # finish a preformatted block
        if /^(```)/.match(line).present? and paragraph.instance_of? PreFragment
          # skip and reset
          line = ""
        end

        # finish the last paragraph and start a new one
        if line == ""
          unless paragraph.content.join("").empty?
            @document_structure << paragraph
            paragraph = ParagraphFragment.new
          end
        end

        # Deal with inline headings
        #
        unless /^(#+)(\s?)\S/.match(line).nil?
          paragraph.content = paragraph.content.delete_if { |i| i == line }
          hashes = $1.dup
          heading = HeadingFragment.new([line.gsub(hashes,'').strip])
          heading.level = hashes.length
          @document_structure << heading
        end

        # Deal with Level 1 Headings
        #
        if !/^(=)+$/.match(line).nil?
          paragraph.content = paragraph.content.delete_if do |item|
            item == line || item == @content[index - 1]
          end
          heading = HeadingFragment.new([@content[index - 1]])
          heading.level = 1
          @document_structure << heading
        end

        # Deal with Level 2 Headings or horizontal rules.
        #
        if !/^(-)+$/.match(line).nil?
          if @content[index - 1].strip == ''
            # Assume it's a horizontal rule
            #
            paragraph.content = paragraph.content.delete_if { |i| i == line }
            @document_structure << HorizontalRuleFragment.new
          else
            paragraph.content = paragraph.content.delete_if do |item|
              item == line || item == @content[index - 1]
            end
            heading = HeadingFragment.new([@content[index - 1]])
          heading.level = 2
          @document_structure << heading
          end
        end

        # Deal with task lists
        #
        if !/^(- \[ \])|(- \[[xX]\])+/.match(line).nil?
          paragraph.content = paragraph.content.delete_if { |i| i == line }
          task = TaskFragment.new([line])
          @document_structure << task
        end

        # Deal with all other kinds of horizontal rules
        #
        if !/^(\*+)(\s)?(\*+)(\s)?(\*+)/.match(line).nil? || !/^(-+)(\s)(-+)(\s)(-+)/.match(line).nil?
          if @content[index - 1].strip == ''
            paragraph.content = paragraph.content.delete_if { |i| i == line }
            @document_structure << HorizontalRuleFragment.new
          end
        end

        # Try to deal with lists.
        #
        if in_list
          # We're in a list just now.
          #

          # Remove the content from the paragraph where it will have
          # automatically been appended
          #
          paragraph.content = paragraph.content.delete_if { |i| i == line }

          # Check to see if we've got a new list item.
          #
          if (!RX_BUL_LIST.match(line).nil? || !RX_NUM_LIST.match(line).nil?)

            # Find out if this new list item is for a different type of list
            # and deal with that before adding the new list item.
            #
            if list.ordered? && !RX_NUM_LIST.match(line).nil?
              @document_structure << list
              list = ListFragment.new
            elsif !list.ordered? && !RX_BUL_LIST.match(line).nil?
              @document_structure << list
              list = ListFragment.new
            list.ordered = true
            end

            # Remove the list style and add the new list item.
            #
            list.content << line.sub(RX_NUM_LIST,'').sub(RX_BUL_LIST,'')

          else
          # If this line isn't a new list item, then it's a continuation for the current
          # list item.
          #
          list.content[-1] += line
          end

          # If the current line is empty, then we're done with the list.
          #
          if line == ''
            @document_structure << list
            list = ListFragment.new
          in_list = false
          end
        else
        # Not currently in a list, but we've detected a list item
        #
          if (!RX_NUM_LIST.match(line).nil? || !RX_BUL_LIST.match(line).nil?)
            ordered = false
            ordered = true if !RX_BUL_LIST.match(line).nil?
            list = ListFragment.new
            list.ordered = ordered
            list.content << line.sub(RX_NUM_LIST,'').sub(RX_BUL_LIST,'')
            paragraph.content = paragraph.content.delete_if { |i| i == line }
          in_list = true
          end
        end

        # Deal with a link reference by adding it ot the list of references
        # DP: don't do this - leave the links inline and intact
        if !/^(\[\S+\]){1}:\s(\S+)\s?(.+)?/.match(line).nil?
          reference, url, title = $1, $2, $3
          paragraph.content = paragraph.content.delete_if { |i| i == line }
          @links_list[:urls_seen] << url
          @links_list[:object].content <<  [ reference, url, "#{title}" ]
        end

        # inline monospace format, single `
        # monospace block ```

        # Deal with blockquote
        #
        unless /^(>+)(\s?)\S/.match(line).nil?
          paragraph.content = paragraph.content.delete_if { |i| i == line }
          hashes = $1.dup
          blockquote = BlockquoteFragment.new([line[1..-1].strip])
          # start a new paragraph
          #@document_structure << blockquote
          paragraph = blockquote
        end

        line.scan( /^(```)/ ) do |val|
          paragraph.content = paragraph.content.delete_if { |i| i == line }
          pre = PreFragment.new([line])
          paragraph = pre
        end

        to_replace = []

        # Deal with inline images
        #
        line.scan(/(?:^|\s)?(\!\[(?:.+?)\]\((.+?)\))/) do |val|
          paragraph.content[-1] = paragraph.content[-1].gsub(val[0],'')
          to_replace << val[0]
          # TODO: parse and handle the image caption also
          @document_structure << ImageFragment.new([val[1]])
        end

        to_replace.each { |v| line.gsub!(v) }
        to_replace = []

        # parse markup tables
        unless /\|/.match(line).nil?
          paragraph.content = paragraph.content.delete_if { |i| i == line }
          line.chomp!("|")
          line.reverse!.chomp!("|").reverse!
          if paragraph.instance_of? TableFragment
            # continue the table
            paragraph.content << line.split("|")
          else
            paragraph = TableFragment.new([line.split("|")])
          end
        end
      end
      if !list.content.empty? && ! @document_structure.include?(list)
        @document_structure << list
        list = ListFragment.new
      end
      @document_structure << paragraph unless paragraph.content == ''
      @document_structure << @links_list[:object] if !@links_list[:urls_seen].empty?
    end

    private

    def detab(string, tabwidth = 2)
      string.split("\n").collect { |line|
        line.gsub(/(.*?)\t/) do
          $1 + ' ' * (tabwidth - $1.length % tabwidth)
        end
      }.join("\n")
    end

    # Only do Inline formatting for versions of Prawn which support it.
    #
    def process_inline_formatting(str)
      breg = [ %r{ \b(\_\_) (\S|\S.*?\S) \1\b }x, %r{ (\*\*) (\S|\S.*?\S) \1 }x ]
      ireg = [ %r{ (\*) (\S|\S.*?\S) \1 }x, %r{ \b(_) (\S|\S.*?\S) \1\b }x ]
      if Prawn::VERSION =~ /^0.1/ || Prawn::VERSION =~ /^1/ || Prawn::VERSION =~ /^2/
        str = str.gsub(breg[0], %{<b>\\2</b>} ).gsub(breg[1], %{<b>\\2</b>} ).gsub(ireg[0], %{<i>\\2</i>} ).gsub(ireg[1], %{<i>\\2</i>} )
      else
        str = str.gsub(breg[0], %{\\2} ).gsub(breg[1], %{\\2} ).gsub(ireg[0], %{\\2} ).gsub(ireg[1], %{\\2} )
      end
    end

  end

end
