module Jekyll
  class AllLinks < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @given_path = text
    end

    def render(context)

      windows_path = @given_path.gsub("/",'\\')
      unix_path = @given_path
      mac_path = @given_path
      output = "<ul class=\"unstyled\">\n"
      output += "<li><span class=\"label\">Windows</span> "
      output += "<a href=\"file:///\\\\sgc-core\\core/#{windows_path}\">\\\\sgc-core\\core\\#{windows_path}</a></li>\n"
      output += "<li><span class=\"label\">UNIX</span>       "
      output += "<a href=\"file:////n/facility/#{unix_path}\">/n/facility/#{unix_path}</a></li>\n"
      output += "<li><span class=\"label\">Mac</span>        "

      output += "<a href=\"smb://sgc-core.sgc.loc/core/#{mac_path}\">smb://sgc-core.sgc.loc/core/#{mac_path}</a></li>\n"
      output += "</ul>\n"
      output
    end

  end
end

Liquid::Template.register_tag('all_links', Jekyll::AllLinks)

