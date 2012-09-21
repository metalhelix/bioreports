module Jekyll
  class AllLinks < Liquid::Tag

    ROOTS = { "facility" =>
                  {:win => "ion\\core", :mac => "ion.sgc.loc/core", :nix => "n/facility", :web => "bioinfo/n/facility"},
              "core" =>
                  {:win => "ion\\core", :mac => "ion.sgc.loc/core", :nix => "n/core", :web => "bioinfo/n/core"},
              "analysis" =>
                  {:win => "ion\\solexa-analysis", :mac => "ion.sgc.loc/solexa-analysis", :nix => "n/analysis", :web => "bioinfo/n/analysis"},
              "data1" =>
                  {:win => "dm3\\data1", :mac => "dm3.sgc.loc/data1", :nix => "n/data1", :web => "bioinfo/n/data1"},
              "projects" =>
                  {:win => "ion\\projects", :mac => "ion.sgc.loc/projects", :nix => "n/projects", :web => "bioinfo/n/projects"}
    }


    SYNTAX = /(\S+)\s?([\w\s=]+)*/

    # def initialize(tag_name, text, tokens)
    #   super
    #   puts text
    #   if text =~ SYNTAX
    #     @given_path = $1
    #     tmp_options = {}
    #     puts $2
    #     if defined? $2
    #       $2.split.each do |opt|
    #         key, value = opt.split('=')
    #         if value.nil?
    #           if ROOTS.keys.include?(key)
    #             tmp_key = key
    #             key = 'base_dir'
    #             value = tmp_key
    #           else
    #             value = true
    #           end
    #         end
    #         tmp_options[key] = value
    #       end
    #     else
    #       tmp_options['base_dir'] = 'facility'
    #     end
    #     @options = tmp_options
    #     puts @options.inspect
    #   else
    #       raise SyntaxError.new("Syntax Error in 'file_links' - Valid syntax: file_links <path> [base_dir]")
    #   end
    # end
    #
    
    def initialize(tag_name, text, tokens)
      text_data = text.strip.split('/').reject {|d| !d or d.empty?}
      text_data.shift if text_data[0].strip == "n"
      @base_dir = text_data.shift
      @given_path = text_data.join('/')
    end

    def render(context)

      #dir = @options['base_dir']
      dir = @base_dir

      windows_path = @given_path.gsub("/",'\\')
      unix_path = @given_path
      mac_path = @given_path
      web_path = @given_path
      output = "<div class=\"all-links\"><ul class=\"unstyled\">\n"
      output += "<li><span class=\"label\">Windows</span> "
      output += "<a href=\"file:///\\\\#{ROOTS[dir][:win]}/#{windows_path}\">\\\\#{ROOTS[dir][:win]}\\#{windows_path}</a></li>\n"
      output += "<li><span class=\"label\">UNIX</span>       "
      output += "<a href=\"file:////#{ROOTS[dir][:nix]}/#{unix_path}\">/#{ROOTS[dir][:nix]}/#{unix_path}</a></li>\n"
      output += "<li><span class=\"label\">Mac</span>        "

      output += "<a href=\"smb://#{ROOTS[dir][:mac]}/#{mac_path}\">smb://#{ROOTS[dir][:mac]}/#{mac_path}</a></li>\n"
      output += "<li><span class=\"label\">Web</span>       "
      output += "<a href=\"http://#{ROOTS[dir][:web]}/#{web_path}\">#{ROOTS[dir][:web]}/#{web_path}</a></li>\n"
      output += "</ul></div>\n"
      output
    end

  end
end

Liquid::Template.register_tag('file_links', Jekyll::AllLinks)

