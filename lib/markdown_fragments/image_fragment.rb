require 'net/http'
require 'tmpdir'

class ImageFragment < MarkdownFragment
  def render_on(pdf)
    width = pdf.bounds.width*0.80

    if @content.first.include?('/assets/')
      file_path = File.join(Rails.root, "app", "assets", @content.first.gsub("/assets/","/images/"))
    else
      file_path = @content.first
    end
    begin
      if is_svg?
        s = Prawn::Svg::Interface.new(open(file_path), pdf, :at=>[0,0])
        pdf.svg open(file_path), :width=>[s.document.sizing.output_width, pdf.bounds.width*0.80].min, :at=>[(pdf.bounds.width - width)/2, pdf.cursor]
      else
        i, info = pdf.build_image_object open(file_path)
        pdf.image open(file_path), :width=>[info.width, pdf.bounds.width*0.80].min, :position=>:center
      end
    rescue Exception=>e
      pdf.text "Image reference error: %s" % e.message, :color=>"ff0000"
    end
  end

  private

  def is_svg?
    @content.first.downcase.include?(".svg")
  end

  def is_remote_uri?
    !/^(http:|https:)/.match(@content.first).nil?
  end

end
