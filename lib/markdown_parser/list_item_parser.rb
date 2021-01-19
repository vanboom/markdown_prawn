require File.dirname(__FILE__) + '/../markdown_fragments.rb'

module MarkdownPrawn
  RX_BUL_LIST = /^\s?\*\s/
  RX_NUM_LIST = /^\s?\d+\.\s/
  RX_SUB_BUL_LIST = /^\s*\*\s/
  RX_SUB_NUM_LIST = /^\s*\d+\.\s/

  # Horribly bodgy and wrong markdown parser which should just about do
  # for a proof of concept. Some of the code comes from mislav's original
  # BlueCloth since I cant find the source of a newer versoin.
  #
  class ListItemParser
    attr_accessor :list_fragment
    attr_accessor :prev_line

    def initialize
      @list_fragment = nil
    end

    ##
    # process the line and return anyting for the document
    def process_line(line, document)
      consume = nil
      # if we need to open a list?
      if list_open?
        # are we continuing the list
        if same_list_item?(line)
          consume = line
          add_to_list(line)
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
      @list_fragment.content << line.sub(RX_NUM_LIST, '').sub(RX_BUL_LIST, '')
    end

    def append_last_item(line)
      @list_fragment.content[-1] += (" " + line)
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
