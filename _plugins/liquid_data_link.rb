require File.join(File.dirname(__FILE__), "table_builder.rb")

module Jekyll
  class DataPage < Page
    attr_accessor :link_path, :data_source
    def initialize(site, base, dir, data_source, config)
      @site = site
      @base = base
      @dir = dir
      @name = File.basename(data_source).split(".")[0..-2].join(".") + ".html"

      self.link_path = File.join(@dir, @name)
      self.data_source = data_source

      self.process(@name)

      self.read_yaml(File.join(base, '_layouts'), "#{config['data_layout']}.html")
      self.content = TableBuilder.build_from_file data_source, {:class => 'big_table'}
      self.data['layout'] = 'data'
      #self.data['data_source'] = data_source.gsub(context.registers[:site].source, "")
    end
  end
end

module Jekyll
  class DataPageGenerator
    def initialize
    end

    def generate(site, source)
      config = {}
      config = config.merge!({
        'page_dir'    => "data_dir",
        'data_layout'    => "data",
      }){ |key, v1, v2| v1 }

      dir = site.config[config['page_dir']] || 'data_pages'

      page = write_data_page(site, dir, source, config)
      page
    end

    def write_data_page(site, dir, data_source, config)
      index = DataPage.new(site, site.source, dir, data_source, config)
      index.render(site.layouts, site.site_payload)
      index.write(site.dest)
      site.static_files << index
      index
    end
  end
end

module Jekyll
  class DataLinkTag < Liquid::Tag
    def initialize(tag_name, file, tokens)
      super
      @file = file.strip
    end

    def render(context)
      data_file = File.expand_path(@file, context.registers[:site].source)
      output = "<span class=\"error\">File not found: #{@file}</span>"

      if File.exists? data_file
        generator = DataPageGenerator.new
        page = generator.generate(context.registers[:site], data_file)
        output = "<a class=\"btn primary\" href=\"#{page.link_path}\">#{File.basename(page.data_source)}</a>"
      end

      output
    end
  end
end

Liquid::Template.register_tag('data_link', Jekyll::DataLinkTag)

