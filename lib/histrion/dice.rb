
module Histrion

  class << self

    if RUBY_PLATFORM.match?(/openbsd/)

      def rand(a, b)

        r = File.open('/dev/urandom', 'rb') { |f| f.read(7) }
          .codepoints.collect(&:to_s).join
          .to_i
        d = b - a + 1

        a + (r % d)
      end

    else

      def rand(a, b)

        ::Kernel.rand(a..b)
      end
    end

    def roll(s)

      Histrion::Dice.new(s).roll
    end
  end

  class Dice

    def initialize(s)

      @dice = self.class.parse(s)
    end

    def roll

      @dice.inject(0) { |r, d|
        if d.is_a?(Array)
          count, sides = d
          (count || 1).times { r = r + Histrion.rand(1, sides) }
        else
          r = r + d
        end
        r }
    end

    class << self

      def parse(s)

        return nil unless s.is_a?(String)

        a = []
        k = ::StringScanner.new(s)

        loop do
          c = k.scan(/\d+/)
          d = k.scan(/d\d+/); break unless d
          a << [ c ? c.to_i : nil, d[1..-1].to_i ]
        end

        d = k.scan(/[-+]\d+/)
        a << d.to_i if d

        k.eos? ? a : nil
      end
    end
  end
end

