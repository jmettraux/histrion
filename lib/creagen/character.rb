
class Creagen::Character < Creagen::Creature

  #def initialize
  #  super
  #end

  def background=(b, meth=nil)

    @background = b[:name]

    inc_skill(b[:free])

    meth =
      meth ?
      "apply_background_#{meth}" :
      [ :apply_background_quick,
        :apply_background_learn,
        :apply_background_roll ].shuffle(random: @rnd).first

    self.send(meth, b)
  end

  def attack_bonus

    if @kla
      @kla[:levels][level][:attack]
    else
      fail NotImplementedError.new("(HD / 2 rounded up)")
    end
  end
  alias ab attack_bonus

  def klass=(c)

    @kla = c
    l0 = c[:levels][0]

    #
    # hit points

    @hd = l0[:hp]
    r = Creagen.roll(@hd)
    r = r + con_mod * 1
    @hp = [ 1, r ].max

    #
    # foci

    @foci = {}
    count = l0[:foci]
      #
    while @foci.count < count do

      f = pick(Creagen::FOCI)
      n = f[:name]
      l = @foci[n]; next if l == 2
      l = @foci[n] = (l || 0) + 1

      if l == 1
        m = f[:module]; self.singleton_class.include(m) if m
        v = f[:lambda]; v[self] if v
        (f[:skills] || []).each do |s|
          s = pick(s) if s.is_a?(Array)
          inc_skill(s)
        end
      end
    end

    #
    # weapons

    @weapons += c[:weapons]
      .collect { |e|
        if e.is_a?(Array)
          Creagen::WEAPONS[pick(e)]
        else
          Creagen::WEAPONS[e]
        end.dup }
      .compact
  end

  def pick_a_skill

    s = @kla[:skill]

    if s && (@skills[s] || -1) < 0
      inc_skill(s)
    else
      while grow_any_skill == false; end
    end
  end

  protected

  def apply_background_quick(b)

    b[:quick].each { |s| inc_skill(s) }
  end

  def apply_background_learn(b)

    skills = []
    while skills.count < 2
      s = b[:learning].shuffle(random: @rnd).first
      skills << s unless s.start_with?('Any ')
    end

    skills.each { |s| inc_skill(s) }
  end

  def apply_background_roll(b)

    3.times do
      self.send(
        [ :apply_background_roll_growth, :apply_background_roll_learning ]
          .shuffle(random: @rnd)
          .first,
        b)
    end
  end

  def apply_background_roll_growth(b)

    case g = pick(b[:growth])
    when /^\+/ then inc_attribute(g)
    when /^Any Combat$/i then grow_combat_skill
    when /^Any Skill$/i then grow_any_skill
    else inc_skill(g)
    end
  end
end

