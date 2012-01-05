require File.join(File.dirname(__FILE__), "table_builder.rb")

module Jekyll
  class TableBlock < Liquid::Block
    include Liquid::StandardFilters

    DEFAULT_TYPE = "csv"
    VALID_TYPES = [DEFAULT_TYPE, "tsv"]

    def initialize(tag_name, markup, tokens)
      super
      @data_type = markup.strip
      if !@data_type or @data_type.empty? or !VALID_TYPES.include?(@data_type)
        @data_type = DEFAULT_TYPE
      end
    end

    def render(context)
      TableBuilder.render_table(super, @data_type)
    end
  end
end

Liquid::Template.register_tag('table', Jekyll::TableBlock)

