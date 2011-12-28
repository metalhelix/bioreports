require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'liquid_table_block'

describe Jekyll::TableBlock do
  def create_post(content, override = {}, converter_class = Jekyll::MarkdownConverter)
    stub(Jekyll).configuration do
      Jekyll::DEFAULTS.merge({'pygments' => true}).merge(override)
    end
    site = Site.new(Jekyll.configuration)
    info = { :filters => [Jekyll::Filters], :registers => { :site => site } }
    @converter = site.converters.find { |c| c.class == converter_class }
    payload = { "pygments_prefix" => @converter.pygments_prefix,
                "pygments_suffix" => @converter.pygments_suffix }

    @result = Liquid::Template.parse(content).render(payload, info)
    @result = @converter.convert(@result)
  end

  def fill_post(code, override = {})
    content = <<CONTENT
---
title: This is a test
---

This document results in a markdown error with maruku

{% highlight text %}#{code}{% endhighlight %}
CONTENT
    create_post(content, override)
  end

  describe "textile" do

    before :each do
      @content = <<CONTENT
---
title: Maruku vs. RDiscount
---

_FIGHT!_

{% highlight ruby %}
puts "3..2..1.."
{% endhighlight %}

*FINISH HIM*
CONTENT
    create_post(@content, {}, Jekyll::TextileConverter)
    end
  end
end



