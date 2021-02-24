
#
# Specifying histrion
#
# Sat Jan 30 15:02:03 JST 2021
#

require 'histrion'


module Helpers
end

RSpec.configure do |c|

  c.alias_example_to(:they)
  c.alias_example_to(:so)
  c.include(Helpers)
end

#RSpec::Matchers.define :eqj do |o|
#
#  match do |actual|
#
#    return actual.strip == JSON.dump(o) if o.is_a?(String)
#    JSON.dump(actual) == JSON.dump(o)
#  end
#
#  #failure_message do |actual|
#  #  "expected #{encoding.downcase.inspect}, got #{$vic_r.to_s.inspect}"
#  #end
#
#  #failure_message_for_should do |actual|
#  #end
#  #failure_message_for_should_not do |actual|
#  #end
#end

#RSpec::Matchers.define :eqd do |o|
#
#  o = Flor.to_d(o) unless o.is_a?(String)
#  o = o.strip
#
#  match do |actual|
#
#    return Flor.to_d(actual) == o
#  end
#
#  failure_message do |actual|
#
#    "expected #{o}\n" +
#    "     got #{Flor.to_d(actual)}"
#  end
#end

#class String
#
#  def sstrip
#
#    self.gsub(/\A[ \t]*\n/, '').rstrip
#  end
#end

