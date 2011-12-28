$TESTING=true

require 'simplecov'
SimpleCov.start do
  add_group 'Libraries', 'lib'
  add_group 'Specs', 'spec'
end

require 'jekyll'
$:.unshift(File.join(File.dirname(__FILE__), "..", "_plugins"))

require 'stringio'

require 'rdoc'
require 'rspec'

# require 'fakefs/spec_helpers'

ARGV.clear

RSpec.configure do |config|
  # config.include FakeFS::SpecHelpers, fakefs: true

  config.before :each do
    ARGV.replace []
  end

  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end

  alias :silence :capture
end

