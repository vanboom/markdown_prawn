description = "Markdown Parawn is a library and an executable script which allow you to generate a PDF from any valid Markdown. Thanks to Ryan Stenhouse for starting this development!" 
Gem::Specification.new do |spec|
  spec.name = "markdown_prawn"
  spec.version = '0.0.12'
  spec.platform = Gem::Platform::RUBY
  spec.files =  Dir.glob("{bin,lib,test}/**/**/*") +
                      ["Rakefile", "markdown_prawn.gemspec"]
  spec.require_path = "lib"
  spec.required_ruby_version = '>= 1.8.7'
  spec.required_rubygems_version = ">= 1.3.6"

  spec.test_files = Dir[ "test/*_test.rb" ]
  spec.has_rdoc = false
  spec.author = "Don Vanboom"
  spec.email = "dvboom@hotmail.com"
  spec.rubyforge_project = "markdown_prawn"
  spec.add_dependency('prawn')
  spec.homepage = "http://github.com/vanboom"
  spec.summary = description
  spec.description = description
  spec.executables << 'md2pdf'
end
