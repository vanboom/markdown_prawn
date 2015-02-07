#!/usr/bin/env ruby
require 'rubygems'
require 'prawn'
module MarkdownPrawn
  # Namespace for PDF Fun
end

require 'markdown_parser'
require 'extension'
require 'markdown_fragments'
require 'markdown_prawn_exceptions.rb'

Prawn::Document.extensions << MarkdownPrawn::Extension
