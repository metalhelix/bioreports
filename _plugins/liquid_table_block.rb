require File.join(File.dirname(__FILE__), "table_builder.rb")

module Jekyll
  class TableBlock < Liquid::Block
    include Liquid::StandardFilters

    DEFAULT_TYPE = "csv"
    VALID_TYPES = [DEFAULT_TYPE, "tsv"]

    SYNTAX = /(\w+)\s?([\w\s=,]+)*/
    def initialize(tag_name, markup, tokens)
      super
      @options = {:class => "data_table display"}
      @data_type = DEFAULT_TYPE
      if markup =~ SYNTAX
        @data_type = $1.strip
        if defined? $2
          $2.split(',').each do |opt|
            key, value = opt.split('=')
            if key and value
              @options[key.strip.to_sym] = value.strip
            else
              puts "ERROR: invalid option for table"
              puts $2
            end
          end
        end
      else
        puts "ERROR: invalid input for table"
        puts markup
      end
    end

    def render(context)
      TableBuilder.render_table(super, @data_type, @options)
    end
  end
end

Liquid::Template.register_tag('table', Jekyll::TableBlock)

