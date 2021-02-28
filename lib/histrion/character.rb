
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
      klass_level[:attack]
    else
      fail NotImplementedError.new("(HD / 2 rounded up)")
    end
  end
  alias ab attack_bonus

  def foci_level_count

    @foci.inject(0) { |r, (_, v)| r + v }
  end

  def klass=(c)

    @kla = c
    l0 = c[:levels][0]

    #
    # hit points

    @hd = l0[:hp]
    hp = Histrion.roll(@hd) + con_mod
    @hp = [ hp, 1 ].max

    #
    # foci

    @foci = {}
      #
    while foci_level_count < l0[:foci]
      pick_focus
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
      77.times { break if grow_any_skill }
    end
  end

  def pick_spells

    return if magic < 0

    @spells ||= []
    (@kla[:spells] || lambda { |c| })[self]
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

  def level_up

    @level = level + 1

    new_hp = Histrion.roll(klass_level[:hp]) + level * con_mod
    @hp = [ hp + 1, new_hp ].max

    lc1 = foci_level_count + (klass_level[:foci] || 0)

    while foci_level_count < lc1
      pick_focus
    end

    @spare_skill_points = (@spare_skill_points || 0) + 3

    consume_skill_points

    pick_spells
  end

  def to_h(opts={})

    h = super(opts.merge(raw: true))

    h[:class] = @kla[:name]
    h[:background] = background
    h[:type] = 'Character'

    %w[ goods ].each do |k|
      v = self.send(k)
      h[k] = v unless v.is_a?(Array) && v.empty?
    end

    sps = @spare_skill_points; h[:sps] = sps if sps && sps > 0

    h1 = h
    h1 = h.keys.sort_by(&:to_s).inject({}) { |hh, k| hh[k] = h[k]; hh }

    opts[:raw] ? h1 : JSON.parse(JSON.dump(h1))
  end

  class << self

    def from_h(h)

      opts = Histrion::Options.new(h['argv'] || [])

      c = self.allocate

      class << c
        def _set(a, b)
          if a.is_a?(Hash) && b.is_a?(Symbol)
            h, k = a, b
            instance_variable_set("@#{k}", h[k.to_s])
          else
            k, v = a, b
            instance_variable_set("@#{k}", v)
          end
        end
      end

      h['attributes'].each { |k, v| c.send("#{k}=", v) }

      c._set(:opts, opts)
      c._set(:kla, opts.klasses.find { |c| c[:name] == h['class'] })

      c._set(h, :hp)
      c._set(h, :skills)
      c._set(h, :morale)
      c._set(h, :foci)

      c._set(:weapons, h['weapons'].collect { |n| opts.weapons[n] })

      c
    end

    def load(path); from_h(YAML.load_file(path)); end
  end

  def add_petty_goods

    [ 0, 1, 1, 1, 2, 2, 3 ].shuffle(random: rnd).first
      .times { @goods << @opts.random_petty_good }
  end

  protected

  def consume_skill_points

    caster = @skills.keys.include?('Magic')

    7.times do

      skill_name =
        if caster
          pick(@opts.skills, [ 'Magic' ] * 5)
        else
          pick(@opts.skills_without_magic)
        end
      skill_cost =
        compute_skill_cost(skill_name)
      if skill_cost <= @spare_skill_points
        @spare_skill_points -= skill_cost
        @skills[skill_name] = (@skills[skill_name] || -1) + 1
      end
      break if @spare_skill_points < 1
    end
  end

  # A character cannot develop skills beyond level-4.
  #
  # | New Skill Level | Skill Point Cost | Min Char Level |
  # |-----------------|------------------|----------------|
  # | 0               | 1                | 1              |
  # | 1               | 2                | 1              |
  # | 2               | 3                | 3              |
  # | 3               | 4                | 6              |
  # | 4               | 5                | 9              |
  #
  def compute_skill_cost(skill_name)

    max_skill_level =
      case level
      when 1..2 then 1
      when 3..5 then 2
      when 6..8 then 3
      else 4; end

    current_level = @skills[skill_name] || -1
    new_level = current_level + 1

    return 9999 if new_level > max_skill_level # making it too costly

    new_level + 1
  end

  def pick_focus

    f = pick(@opts.foci)

    r = f[:requisite]; return if r && ! r[self]

    n = f[:name]
    l = @foci[n]; return if l == 2
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

  def klass_level

    @kla[:levels][level - 1]
  end

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

