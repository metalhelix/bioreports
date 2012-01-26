
module Jekyll
  class ImageLink < Liquid::Tag
    SYNTAX = /(\S+)\s?([\w\s=,]+)*/
    def initialize(tag_name, text, tokens)
      @options = {:class => "medium"}
      if text =~ SYNTAX
        @image = $1.strip
        if defined? $2
          $2.split(',').each do |opt|
            key, value = opt.split('=')
            if key and value
              @options[key.strip.to_sym] = value.strip
            else
              puts "ERROR: invalid option for image_link"
              puts $2
            end
          end
        end
      else
        puts "ERROR: invalid input for image_link"
        puts text
      end
    end

    def render(context)
      page_id = context.registers[:page]["id"]
      image_url = "data/#{page_id}/#{@image}".gsub("//","/")
      image_class = @options[:class]
      "!(#{image_class})#{image_url}!:#{image_url}"
    end
  end
end

Liquid::Template.register_tag('image_link', Jekyll::ImageLink)
