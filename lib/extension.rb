module MarkdownPrawn
  module Extension
    #
    # Draws Github flavored markdown into the PDF
    #
    #   markdown "some markdown"
    #
    def markdown(data, options = {})
      return false if data.nil?
      # we modify the options. don't change the user's hash
      options = options.dup
      # parse the markdown to prawn
      parser = MarkdownPrawn::StringParser.new(data)
      parser.parse!
      parser.document_structure.each do |fragment|
        fragment.render_on(self, options)
      end
    end
  end
end
