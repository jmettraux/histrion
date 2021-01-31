
module FeetExpander

  class << self

    def expand(s, &block)

      s
        .gsub(
          %r{
            (\d+\/)?
            (\d[.,]\d+|[.,]\d+|\d+)[- ]*
            (foot|feet|ft\.?)
          }xi) {
            r = expand_feet($1, $2, $3)
            block ? block.call(r) : r
          }
    end

    #def list_to(max)
    #  f = 5
    #  loop do
    #    break if f > max
    #    puts expand("#{f} feet")
    #    f = f + 5
    #  end
    #end
    #def list_csv_to(max)
    #  f = 5
    #  loop do
    #    break if f > max
    #    puts expand("#{f} feet").gsub(/(ft|m|sq)/, '').gsub(/_/, ',')
    #    f = f + 5
    #  end
    #end

    protected

    def expand_feet(r0, r1, unit)

      [ r0 ? do_expand_feet(r0) : nil, do_expand_feet(r1) ]
        .compact.join(' / ')
    end

    def rtos(range)

      case r = ("%.1f" % range)
      when /\.[1-9]/ then r.to_f.to_s
      when /\.0*/ then r.to_i.to_s
      else r
      end
    end

    def do_expand_feet(range)

      ft = range.to_i; return '0ft' if ft == 0
      m = ft * 0.3
      sq = ft * 0.2

      st =
        tost(ft)
      st =
        case st
        when '+5' then 't-1'
        when '+4' then 't-2'
        when /^\+/ then nil
        else st
        end

      [ "#{rtos(ft)}ft", "#{rtos(m)}m", "#{rtos(sq)}sq", st ]
        .compact
        .join('_')
    end

    def rework_tail(s)

      m = s.match(/^([^+]*)(t)\+(\d+)$/); return nil unless m
      b, t, n = m[1], m[2], m[3].to_i

      return "#{b}F-1" if n == 1
      return nil if n < 2

      n = n - 2
      "F#{b}#{n > 0 ? "+#{n}" : ''}"
    end

    def tost(ft)

      return '' if ft == 0
      return "+#{rtos(ft / 5.0)}" if ft < 30

      t1 = ft / 30
      t1r = ft % 30

      s = "#{'t' * t1}#{tost(t1r)}"
      while rs = rework_tail(s); s = rs; end

      s
        .gsub(/tttt/,
          'FFF')
        .gsub(/[tF]+/) { |s|
          ts, fs = s.count('t'), s.count('F')
          ('F' * fs) + ('t' * ts) }
        .gsub(/F+/) { |s|
          s.length > 3 ? "#{s.length}F" : s }
    end
  end
end

