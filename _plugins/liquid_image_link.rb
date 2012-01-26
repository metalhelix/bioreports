
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

      image_url = nil

      # first attempt to use the data field of the report
      # meta data
      data_dirs = context.registers[:page]["data"]
      data_dirs ||= []

      data_dirs.each do |data_dir|
        image_url = File.join(data_dir, @image)
        full_image_file = File.expand_path(image_url, context.registers[:site].source)
        if File.exists? full_image_file
          break
        end
        image_url = nil
      end


      # if that doesn't work, try to get the data dir by id
      # NOTE: pages don't have an id - only posts
      if !image_url
        page_id = context.registers[:page]["id"]
        image_url = "data/#{page_id}/#{@image}".gsub("//","/")
        full_image_file = File.expand_path(image_url, context.registers[:site].source)
        if !File.exists? full_image_file
          image_url = nil
        end
      end

      image_class = @options[:class]
      if image_url
        "!(#{image_class})#{image_url}!:#{image_url}"
      else
        "ERROR: cannot find #{@image} in #{data_dirs.join(", ")}"
      end
    end
  end
end

Liquid::Template.register_tag('image_link', Jekyll::ImageLink)
