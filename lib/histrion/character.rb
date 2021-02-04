
class Histrion::Character < Histrion::Creature

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
        :apply_background_roll ].shuffle(random: @opts.rnd).first

    self.send(meth, b)
  end

  def flat_morale

    8 + (hd_i.to_f * 0.5).floor
  end

  def morale

    @morale ||= (
      flat_morale +
      Histrion.roll('1d3') - 1 +
      str_mod - wis_mod +
      case @background
      when /noble/i, /religious/i then 1
      when /slave/i, /wanderer/i then -1
      else 0
      end)
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
    r = Histrion.roll(@hd)
    r = r + con_mod * 1
    @hp = [ 1, r ].max

    #
    # foci

    @foci = {}
    count = l0[:foci]
      #
    100.times do

      break if @foci.count >= count

      f = pick(@opts.foci)

      r = f[:requisite]; next if r && ! r[self]

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
          @opts.weapons[pick(e)]
        else
          @opts.weapons[e]
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

  def add_nick

    @nick =
      case Histrion.roll('1d6')
      when 1, 2 then add_son_nick
      when 3, 4 then add_att_nick
      when 5, 6 then add_skill_nick
      #else add_foci_nick
      end
  end

  protected

  def add_son_nick

    if @background.match?(/noble/i)
      case Histrion.roll('1d6')
      when 1, 2 then "of #{@opts.random_place_name}"
      else "son of #{@opts.random_name}"
      end
    else
      "son of #{@opts.random_name}"
    end
  end

  def add_att_nick

    if str > 12 then 'the strong'
    elsif dex > 12 then 'the dextrous'
    elsif con > 12 then 'the tough'
    elsif cha > 12 then 'the flamboyant'
    elsif int > 12 then 'the smart'
    elsif wis > 12 then 'the wise'
    else nil
    end
  end

  def add_skill_nick

    sks = @skills.keys
    s = %w[ Shoot Sneak Punch Craft Hunt Heal Survive Trade ]
      .shuffle(random: @opts.rnd)
      .find { |n| sks.include?(n) }

    s ? "the #{s.downcase}#{s.match?(/e$/) ? 'r' : 'er'}" : nil
  end

  def add_foci_nick

    #p @foci
    nil
  end

  def apply_background_quick(b)

    b[:quick].each { |s| inc_skill(s) }
  end

  def apply_background_learn(b)

    skills = []
    while skills.count < 2
      s = b[:learning].shuffle(random: @opts.rnd).first
      skills << s unless s.start_with?('Any ')
    end

    skills.each { |s| inc_skill(s) }
  end

  def apply_background_roll(b)

    3.times do
      self.send(
        [ :apply_background_roll_growth, :apply_background_roll_learning ]
          .shuffle(random: @opts.rnd)
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

