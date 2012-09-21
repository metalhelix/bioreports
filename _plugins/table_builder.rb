require 'redcloth'

module Jekyll
  class TableBuilder
    def self.build_from_file filename, options = {}
      if !File.exists? filename
        return true
      end

      type = File.extname(filename)[1..-1]
      input = File.open(filename,'r').read
      input ||= ""
      render_table input, type, options
    end

    def self.render_table data_string, type, options = {}
      data = []
      case type
      when "tsv"
        data = split_tsv_data data_string
      when "csv"
        data = split_csv_data data_string
      else
        data = split_csv_data data_string
      end
      data = data.select {|l| !l.empty?}
      if options[:format]
        data = format_data(data, options[:format])
      end
      render_html_table(data, options)
    end

    def self.render_html_table(data, options)
      <<-HTML
<div>
  #{build_html_table(data, options).strip}
</div>
      HTML
    end

    def self.build_html_table data, options
      table_class = options[:class] || "data_table display"
      header = data.shift
      output = "<notextile><table class=\"#{table_class}\">"
      output += "<thead><tr>"
      output += '<th>' + header.join('</th><th>') + '</th>'
      output += "</tr></thead>"
      output += "<tbody>"
      data.each do |data_line|
        output += '<tr>'
        output += '<td>' + data_line.join('</td><td>') + '</td>'
        output += "</tr>"
      end
      output += "</tbody>"
      output += "</table></notextile>"
      output
    end

    def self.format_data(data, format)
      format_data = data
      if format == "textile"
        puts "formatting data in table as textile"

        format_data = data.collect do |line|
          line = line.collect {|d| RedCloth.new(d, [:lite_mode]).to_html}
          line
        end
      else
        puts "unknown format"
      end
      format_data
    end

    def self.split_csv_data(raw_data)
      data = raw_data.strip.split("\n").collect {|l| l.split(",").collect {|d| d.strip}}
      data
    end

    def self.split_tsv_data(raw_data)
      data = raw_data.split("\n").collect {|l| l.split("\t")}
      data.shift if data[0].empty?
      data
    end
  end
end
