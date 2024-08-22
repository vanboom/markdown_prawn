require File.dirname(__FILE__) + '/../markdown_fragments.rb'

module MarkdownPrawn
  RX_BUL_LIST = /^\s?[\*\-]\s/
  RX_NUM_LIST = /^\s?\d+\.\s/
  RX_SUB_BUL_LIST = /^\s*[\*\-]\s/
  RX_SUB_NUM_LIST = /^\s*\d+\.\s/
	SUB_BULLET = "\u2022".encode('utf-8').freeze
  # Horribly bodgy and wrong markdown parser which should just about do
  # for a proof of concept. Some of the code comes from mislav's original
  # BlueCloth since I cant find the source of a newer versoin.
  #
  class ListItemParser
    attr_accessor :list_fragment
    attr_accessor :prev_line
    attr_accessor :sub_item_count

    def initialize
      @list_fragment = nil
      @sub_item_count = 0
    end

    ##
    # process the line and return anyting for the document
    def process_line(line, document)
      # don't confuse task lists with item lists
      return nil if line.include? "- [ ]"
      consume = nil
      # if we need to open a list?
      if list_open?
        # are we continuing the list
        if same_list_item?(line)
          consume = line
          add_to_list(line)
        elsif is_sub_item?(line)
          consume = line
          # pass to sub lit
          add_sub_item(line)
        elsif is_list_item?(line)
          # close and start a new lists
          close_list!(line, document)
          open_new_list!(line)
          add_to_list(line)
          consume = line
        elsif is_list_terminator?(line)
          return close_list!(line, document)
        elsif line != ''
          consume = line
          append_last_item(line)
        end
      elsif is_list_item?(line)
        consume = line
        open_new_list!(line)
        add_to_list(line)
      end
      @prev_line = line.gsub(/\s\s+/, ' ')
      return consume
    end

    def consume_line(line)
      add_to_list(line) if open_new_list!(line)
      # ??? paragraph.content = paragraph.content.delete_if { |i| i == line }
      # consume the line
      line
    end

    def list_open?
      @list_fragment.is_a? ListFragment
    end

    def list_closed?
      @list_fragment.nil?
    end

    def add_to_list(line)
      @list_fragment.content << sanitize(line)
    end

    def sanitize(line)
      line.sub(RX_NUM_LIST, '').sub(RX_BUL_LIST, '').sub(RX_SUB_BUL_LIST, "").sub(RX_SUB_NUM_LIST, "")
    end

    def add_sub_item(line)
      @sub_item_count += 1
      cell0 = is_sub_bulleted?(line) ? SUB_BULLET : "#{@sub_item_count}. "
      if @list_fragment.content.last.is_a? Array
        @list_fragment.content.last << [cell0, sanitize(line)]
      else
        @list_fragment.content << [[cell0, sanitize(line)]]
      end
    end


    def append_last_item(line)
      if @list_fragment.content[-1].is_a?(Array)
        open_new_list!(line)
      else
        @list_fragment.content[-1] += (" " + line)
      end
    end

    def open_ordered!
      @list_fragment = ListFragment.new
      @list_fragment.ordered = true
    end

    def open_bulleted!
      @list_fragment = ListFragment.new
      @list_fragment.ordered = false
    end

    def close_list!(line, document)
      # append_last_item(line)
      document << @list_fragment
      @list_fragment = nil
    end

    def open_new_list!(line)
      @sub_item_count = 0
      if @list_fragment.nil?
        if !RX_NUM_LIST.match(line).nil?
          open_ordered!
        elsif !RX_BUL_LIST.match(line).nil?
          open_bulleted!
        end
      end
    end

    def is_list_item?(line)
      ordered_list_item?(line) || bulleted_list_item?(line)
    end

    def is_sub_ordered?(line)
      !RX_SUB_NUM_LIST.match(line).nil?
    end
    def is_sub_bulleted?(line)
      !RX_SUB_BUL_LIST.match(line).nil?
    end

    def is_sub_item?(line)
      is_sub_bulleted?(line) or is_sub_ordered?(line)
    end

    def ordered_list_item?(line)
      !RX_NUM_LIST.match(line).nil?
    end

    def bulleted_list_item?(line)
      !RX_BUL_LIST.match(line).nil?
    end

    def same_list_item?(line)
      raise 'list fragment is nil' unless @list_fragment.is_a?(ListFragment)
      if @list_fragment.ordered?
        ordered_list_item?(line)
      else
        bulleted_list_item?(line)
      end
    end

    def is_list_terminator?(line)
      !is_list_item?(line) && (@prev_line == '')
      # line == ""
    end
  end
end
