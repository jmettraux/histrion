
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

  def str_s; str < 10 ? " #{str}" : str.to_s; end
  def con_s; con < 10 ? " #{con}" : con.to_s; end
  def dex_s; dex < 10 ? " #{dex}" : dex.to_s; end
  def int_s; int < 10 ? " #{int}" : int.to_s; end
  def wis_s; wis < 10 ? " #{wis}" : wis.to_s; end
  def cha_s; cha < 10 ? " #{cha}" : cha.to_s; end

  attr_reader :rnd

  def str_mod; mod(:str); end
  def con_mod; mod(:con); end
  def dex_mod; mod(:dex); end
  def int_mod; mod(:int); end
  def wis_mod; mod(:wis); end
  def cha_mod; mod(:cha); end
    #
  def str_mod_s; mod_s(:str); end
  def con_mod_s; mod_s(:con); end
  def dex_mod_s; mod_s(:dex); end
  def int_mod_s; mod_s(:int); end
  def wis_mod_s; mod_s(:wis); end
  def cha_mod_s; mod_s(:cha); end

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

    @skills = {}
  end

  def name

    @name || 'Nemo'
  end

  def background

    @background
  end

  def klass

    @kla ? @kla[:name] : @klass
  end

  def level

    @level || @hd || 1
  end

  def physical_save; 16 - level - [ str_mod, con_mod ].max; end
  def evasion_save; 16 - level - [ dex_mod, int_mod ].max; end
  def mental_save; 16 - level - [ wis_mod, cha_mod ].max; end
  def luck_save; 16 - level; end
    #
  alias phy_save physical_save
  alias eva_save evasion_save
  alias men_save mental_save
  alias luc_save luck_save
  alias luk_save luck_save

  def naked_ac; 10 + dex_mod; end
  def ac; 10 + dex_mod; end         # FIXME
  def shield_ac; 14 + dex_mod; end  # FIXME

  def stab; @skills['Stab'] || -2; end
  def shoot; @skills['Shoot'] || -2; end
  def punch; @skills['Punch'] || -2; end

  def to_table(opts={})

    Terminal::Table.new do |t|

      t.style = { width: 64 }

      m = @skills['Magic']
      magic_skills = m ? [ "Magic-#{m}", nil ] : []

      skills =
        [ "Stab-#{stab}", "Shoot-#{shoot}", "Punch-#{punch}" ]
          .reject { |e| e.match(/-2/) } +
        [ nil ] +
        magic_skills +
        (@skills.keys - %w[ Stab Shoot Punch Magic ])
          .map { |k| "#{k}-#{@skills[k]}" }

      t << [
        name,
        background,
        "#{klass} #{level}",
        '' ]
      t << :separator
      t << [
        "STR  #{str_s} (#{str_mod_s})",
        '',
        skills[0],
        rig("HP #{10}") ]
      t << [
        "CON  #{con_s} (#{con_mod_s})",
        "Physical #{phy_save}",
        skills[1],
        @skills['Magic'] ? rig("WP #{10}") : '' ]
      t << [
        "DEX  #{dex_s} (#{dex_mod_s})",
        '',
        skills[2],
        "Ini #{dex_mod_s}" ]
      t << [
        "INT  #{int_s} (#{int_mod_s})",
        "Evasion #{eva_save}",
        skills[3],
        rig("naked AC #{naked_ac}") ]
      t << [
        "WIS  #{wis_s} (#{wis_mod_s})",
        '',
        skills[4],
        rig("AC #{ac}") ]
      t << [
        "CHA  #{cha_s} (#{cha_mod_s})",
        "Mental #{men_save}",
        skills[5],
        rig("shield AC #{shield_ac}") ]
      t << [
        '',
        "Luck #{luk_save}",
        (skills[6..-1] || []).join("\n"),
        '' ]
    end
  end

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

  protected

  def rig(v);
    { value: v, alignment: :right }
  end

  def sgn(i); i < 0 ? i.to_s : "+#{i}"; end

  def mod_s(k)

    sgn(mod(k))
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

