
module Jekyll
  class DataGridTag < Liquid::Tag
    SYNTAX = /(\S+)\s?([\w\s=,]+)*/
    def initialize(tag_name, text, tokens)
      super
      @options = {}
      if text =~ SYNTAX
        @file_path = $1.strip
        if defined? $2
          $2.split(',').each do |opt|
            key, value = opt.split('=')
            if key and value
              @options[key.strip] = value.strip
            else
              puts "ERROR: invalid option for data_grid #{@file_path}"
              puts $2
            end
          end
        end
      else
        puts "ERROR: invalid input for data_grid #{@file_path}"
        puts text
      end
    end


    def render(context)
      data_file = File.expand_path(@file_path, context.registers[:site].source)
      output = "<span class=\"error\">File not found: #{@file_path}</span>"

      if File.exists? data_file
        options_string = @options.collect {|k,v| "#{k}=#{v}"}.join("&")
        output = "<a class=\"btn primary\" href=\"/data_grid.html?file=#{@file_path}&#{options_string}\">#{File.basename(@file_path)}</a>"
      end

      output
    end
  end
end

Liquid::Template.register_tag('data_grid', Jekyll::DataGridTag)

