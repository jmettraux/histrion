
module Creagen; end

require 'creagen/dice'


module Creagen

  class << self

    def generate

      p ARGV
      6.times { p Creagen.rand(1, 6) }
    end
  end
end

