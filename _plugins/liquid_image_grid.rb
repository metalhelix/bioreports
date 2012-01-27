
module Jekyll
  class ImageGrid < Liquid::Block
    include Liquid::StandardFilters
    SYNTAX = /(\d+)?\s?([\w\s=,]+)*/
    def initialize(tag_name, text, tokens)
      super
      @options = {:class => "thumb",
                  :row => nil,
                  :col => nil }
      if text =~ SYNTAX
        # @options[:row] = $1.to_i if $1
        @options[:col] = $1.to_i if $1
        if defined? $2
          $2.split(',').each do |opt|
            key, value = opt.split('=')
            if key and value
              @options[key.strip.to_sym] = value.strip
            else
              puts "ERROR: invalid option for image_grid"
              puts $2
            end
          end
        end
      else
        puts "ERROR: invalid input for image_grid"
        puts text
      end
    end

    def render(context)
      images = get_images(super, context)
      @options[:col] ||= images.size

      output = "<div><table class=\"image-grid\">"

      images.each_slice(@options[:col]).each do |row_images|
        output += "<tr>"
        row_images.each do |img|
          output += "<td><a href=\"#{img}\"><img class=\"#{@options[:class]}\" src=\"#{img}\"/></a></td>"
        end
        output += "</tr>"
      end
      output += "</table></div>"
      output
    end

    def get_images(block_text, context)
      image_names = block_text.strip.split("\n").delete_if {|i| i.empty?}
      images = image_names.collect {|i| find_image(i.strip, context)}
      images
    end

    def find_image(image, context)
      # first attempt to use the data field of the report
      # meta data
      data_dirs = context.registers[:page]["data"]
      data_dirs ||= []

      image_url = nil

      data_dirs.each do |data_dir|
        image_url = File.join(data_dir, image)
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
        image_url = "data/#{page_id}/#{image}".gsub("//","/")
        full_image_file = File.expand_path(image_url, context.registers[:site].source)
        if !File.exists? full_image_file
          image_url = nil
        end
      end
      image_url ||= "imgs/missing.png"
    end
  end
end

Liquid::Template.register_tag('image_grid', Jekyll::ImageGrid)
