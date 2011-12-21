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
      render_table(context, super)
    end

    def render_table(context, code)
      data = []
      case @data_type
      when "tsv"
        data = split_tsv_data code
      when "csv"
        data = split_csv_data code
      else
        data = split_csv_data code
      end
      render_html_table(data)
    end

    def render_html_table(data)
      #The div is required because RDiscount blows ass
      <<-HTML
<div>
  #{build_html_table(data).strip}
</div>
      HTML
    end

    def build_html_table data
      header = data.shift
      output = '<table class="data_table display">'
      output += "<thead><tr>"
      output += '<td>' + header.join('</td><td>') + '</td>'
      output += "</tr></thead>"
      output += "<tbody>"
      data.each do |data_line|
        output += '<tr>'
        output += '<td>' + data_line.join('</td><td>') + '</td>'
        output += "</tr>"
      end
      output += "</tbody>"
      output += "</table>"
      output
    end

    def split_csv_data(raw_data)
      data = raw_data.strip.split("\n").collect {|l| l.split(",").collect {|d| d.strip}}
      data
    end

    def split_tsv_data(raw_data)
      data = raw_data.split("\n").collect {|l| l.split("\t")}
      data.shift if data[0].empty?
      puts data.inspect
      data
    end

  end
end

Liquid::Template.register_tag('table', Jekyll::TableBlock)

