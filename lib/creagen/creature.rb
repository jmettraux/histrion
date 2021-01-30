
class Creagen::Creature

  SKILLS = %w[
    Administer Connect Convince Craft Exert Heal Hunt Know Lead Notice Perform
    Pray Ride Sail Sneak Survive Trade Work ]
  PHYSICAL_ATTRIBUTES = %w[
    strength constitution dexterity ]
  MENTAL_ATTRIBUTES = %w[
    intelligence wisdom charisma ]

  attr_accessor :strength, :constitution, :dexterity
  attr_accessor :intelligence, :wisdom, :charisma

  attr_accessor :klass, :level

  attr_reader :skills

  alias str= strength=
  alias con= constitution=
  alias dex= dexterity=
  alias int= intelligence=
  alias wis= wisdom=
  alias cha= charisma=

  alias str strength
  alias con constitution
  alias dex dexterity
  alias int intelligence
  alias wis wisdom
  alias cha charisma

  attr_reader :rnd

  def str_mod; mod(:str); end
  def con_mod; mod(:con); end
  def dex_mod; mod(:dex); end
  def int_mod; mod(:int); end
  def wis_mod; mod(:wis); end
  def cha_mod; mod(:cha); end

  def score(k); self.send(k.to_s[0, 3]); end

  def initialize

    @rnd = Random.new

    dice = Creagen::Dice.new('3d6')

    self.str = dice.roll
    self.con = dice.roll
    self.dex = dice.roll
    self.int = dice.roll
    self.wis = dice.roll
    self.cha = dice.roll

    @level = 1

    @skills = {}
  end

  def stab; @skills['Stab'] || -2; end
  def shoot; @skills['Shoot'] || -2; end
  def punch; @skills['Punch'] || -2; end

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

  protected

  def mod(k)

    case score(k)
    when -10...3 then -3
    when 3 then -2
    when 4...8 then -1
    when 8...14 then 0
    when 14...18 then 1
    when 18 then 2
    else 3
    end
  end

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

  def inc_attribute(s)

#p [ :inc_attribute, s ]
    m = s.match(/^\+(\d+) (.+)$/)
#p [ :inc_attribute, m[1], m[2] ]

    atts =
      case m[2]
      when /Physical/ then PHYSICAL_ATTRIBUTES
      when /Mental/ then MENTAL_ATTRIBUTES
      else PHYSICAL_ATTRIBUTES + MENTAL_ATTRIBUTES
      end

    m[1].to_i.times do
      att = pick(atts)
      instance_eval "@#{att} = @#{att} + 1"
    end
  end

  def grow_combat_skill

    inc_skill(pick(%w[ Stab Shoot Punch ]))
  end

  def grow_any_skill

    inc_skill(pick(SKILLS))
  end

  def apply_background_roll_learning(b)

    case l = pick(b[:learning])
    when /^Any Combat$/i then grow_combat_skill
    when /^Any Skill$/i then grow_any_skill
    else inc_skill(l)
    end
  end

  def inc_skill(s)

    l = @skills[s] || -1

    return false if l > 0

    @skills[s] = l + 1

    true
  end

  def pick(a); a.shuffle(random: @rnd).first; end
end

