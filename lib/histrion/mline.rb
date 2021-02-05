
class Histrion::Mline

  def initialize(width)

    @width = width

    @lines = [ '' ]
  end

  def <<(s)

    ll = @lines.last

    if ll.length + s.length < @width
      @lines[-1] = ll + s
    else
      @lines[-1] = ll.strip
      @lines << s
    end
  end

  def length

    @lines.inject(0) { |l, s| l + s.length }
  end

  def any?

    @lines.last.length > 0
  end

  def to_s

    @lines.join("\n")
  end
end

