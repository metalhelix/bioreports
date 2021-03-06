require 'inflection'

module Jekyll
  class GenericPageTypeIndex < Page
    attr_accessor :page_type

    def initialize(site, base, dir, page, page_type, subpages, config)
      @page_type = page_type
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), "#{config['index_page']}.html")
      self.data[@page_type] = page
      self.data['sub_pages'] = subpages.sort {|a,b| b <=> a}

      if config['do_related']
        self.data[config['related_key']] = []
        site_coll = site.send ::Inflection.plural(page_type)
        site_coll[page].each do |post|
          post_coll = post.send ::Inflection.plural(page_type)
          post_coll.each do |rel|
            self.data[config['related_key']].push(rel)
          end
        end
        self.data[config['related_key']] = self.data[config['related_key']].uniq
      end

      self.data['title'] = "#{config["title_prefix"]}#{page}"
    end
  end

  class GenericPageTypeList < Page
    attr_accessor :page_type

    def initialize(site,  base, dir, pages, page_type, config)
      @page_type = page_type
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), "#{config['list_page']}.html")
      self.data[::Inflection.plural(@page_type)] = pages
    end
  end

  class GenericPageGenerator < Generator
    safe true

    def generate(site)
      if site.config.has_key?('index_pages') == false
        return true
      end

      site.config['index_pages'].each do |page_type|
        config = {}
        if page_type.is_a?(Hash)
          page_type, config['do_related'] = page_type.shift
        elsif page_type.is_a?(Array)
          page_type, config = page_type
        end

        config = config.merge!({
          'do_related'  => false,
          'page_title'  => page_type.capitalize + ': ',
          'index_page'  => "#{page_type}_index",
          'list_page'   => "#{page_type}_list",
          'page_dir'    => "#{page_type}_dir",
          'pluralize'    => true,
          'related_key' => "related"
        }){ |key, v1, v2| v1 }

        dir = site.config[config['page_dir']] || ::Inflection.plural(page_type)

        #puts site.posts.collect{|p| p.data}

        page_types = nil
        if config['pluralize']
          page_types = site.post_data[::Inflection.plural(page_type)]
        else
          page_types = site.post_data[page_type]
        end

        if site.config['matches'][page_type]
          page_types = combine_matches(page_types, site.config['matches'][page_type])
        end


        if page_types && site.layouts.key?(config['index_page'])
          page_types.each do |page, sub_pages|

            write_index(site, File.join(dir, page.gsub(/\s/, "-").gsub(/[^\w-]/, '').downcase), page, page_type, sub_pages, config)
          end
        end

        if page_types && site.layouts.key?(config['list_page'])
          write_list(site, dir, page_types.keys.sort, page_type, config)
        end
      end
    end

    def combine_matches(page_groups, match_data)
      matched_pages = {}
      match_data.each do |key, matches|
        [key,matches].flatten.each do |match|
          if page_groups.include?(match)
            matched_pages[key] ||= []
            matched_pages[key].concat(page_groups.delete(match))
            # matched_pages[key].concat(page_groups[match])
          end
        end
      end
      # match not found
      page_groups.each do |pkey, pages|
        if !matched_pages.include?(pkey)
          matched_pages[pkey] = pages
        end
      end

      page_groups.replace(matched_pages)

      matched_pages
    end

    def write_index(site, dir, page, page_type, pages, config)
      index = GenericPageTypeIndex.new(site, site.source, dir, page, page_type, pages, config)
      index.render(site.layouts, site.site_payload)
      index.write(site.dest)
      site.static_files << index
    end

    def write_list(site, dir, pages, page_type, config)
      index = GenericPageTypeList.new(site, site.source, dir, pages, page_type, config)
      index.render(site.layouts, site.site_payload)
      index.write(site.dest)
      site.static_files << index
    end
  end
end

