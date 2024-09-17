#!/usr/bin/env ruby
require 'rubygems'
require 'prawn'
require 'active_support'
require 'active_support/core_ext/object'
require 'strscan'

module MarkdownPrawn
  # Namespace for PDF Fun
end

require 'markdown_parser'
require 'extension'
require 'markdown_fragments'
require 'markdown_prawn_exceptions.rb'

Prawn::Document.extensions << MarkdownPrawn::Extension
