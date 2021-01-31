
class Creagen::Creature

  SKILLS = %w[
    Administer Connect Convince Craft Exert Heal Hunt Know Lead Notice Perform
    Pray Ride Sail Sneak Survive Trade Work ]
  PHYSICAL_ATTRIBUTES = %w[
    strength constitution dexterity ]
  MENTAL_ATTRIBUTES = %w[
    intelligence wisdom charisma ]

  attr_accessor :name

  attr_accessor :strength, :constitution, :dexterity
  attr_accessor :intelligence, :wisdom, :charisma

  attr_reader :hp

  attr_reader :skills, :weapons

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
    @weapons = []
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

    @level || 1
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
  def ac; naked_ac; end

  def shield_ac
    sac = 15 + dex_mod
    if sac > ac
      sac
    else
      ac + 1
    end
  end

  def stab; @skills['Stab'] || -2; end
  def shoot; @skills['Shoot'] || -2; end
  def punch; @skills['Punch'] || -2; end

  def wp

    (1 + [ 1, int_mod, wis_mod, cha_mod ].max) * level
  end

  def to_table(opts={})

    Terminal::Table.new do |t|

      t.style = {
        width: 82,
        border_left: false, border_right: false }
        #border_bottom: false }

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
        { value: (name || '').upcase, colspan: 2 },
        background,
        "#{klass} #{level}" ]

      t << :separator

      if @foci
        t << [
          { value: @foci
            .collect { |k, v| "#{k}#{v > 1 ? " #{v}" : ''}" }
            .join(', '),
            colspan: 3 },
          FeetExpander.expand('30 feet') ] #'30ft_9m_6sq_t' ]
        t << :separator
      end

      t << [
        '',
        "STR  #{str_s} (#{str_mod_s})",
        skills[0],
        rig("HP #{hp}") ]
      t << [
        { value: "Physical #{phy_save}", alignment: :right },
        "CON  #{con_s} (#{con_mod_s})",
        skills[1],
        @skills['Magic'] ? rig("WP #{wp}") : '' ]
      t << [
        '',
        "DEX  #{dex_s} (#{dex_mod_s})",
        skills[2],
        "Ini #{dex_mod_s}" ]
      t << [
        { value: "Evasion #{eva_save}", alignment: :right },
        "INT  #{int_s} (#{int_mod_s})",
        skills[3],
        rig("naked AC #{naked_ac}") ]
      t << [
        '',
        "WIS  #{wis_s} (#{wis_mod_s})",
        skills[4],
        rig("AC #{ac}") ]
      t << [
        { value: "Mental #{men_save}", alignment: :right },
        "CHA  #{cha_s} (#{cha_mod_s})",
        skills[5],
        rig("shield AC #{shield_ac}") ]
      t << [
        { value: "Luck #{luk_save}", alignment: :right },
        '',
        (skills[6..-1] || []).join("\n"),
        "Att #{sgn(ab)}" ]

      t << :separator

      nwidth = 7 # weapon name width
      swidth = 9 # shock width

      weapons.each do |w|
        if w[:attributes].include?('strength')
          nic = w[:nick]
          att = sgn(stab + str_mod + ab)
          dmg = w[:damage] + str_mod_s
          s, a = w[:shock]
          sho = "%d%s AC %d" % [ s, sgn(str_mod), a ]
          v = "%#{nwidth}s STR  att %s  dmg %s  shock %#{swidth}s" % [
            nic, att, dmg, sho ]
          t << [ { value: v, colspan: 4 } ]
        end
        if w[:attributes].include?('dexterity')
          if r = w[:range]
            nic = w[:nick]
            att = sgn(stab + dex_mod + ab)
            dmg = w[:damage] + dex_mod_s
            ran = r.collect { |e| FeetExpander.exp(e) }.join('  ')
            v = "%#{nwidth}s DEX  att %s  dmg %s        %#{swidth}s  %s" % [
              nic, att, dmg, '', ran ]
            t << [ { value: v, colspan: 4 } ]
          else
            nic = w[:nick]
            att = sgn(stab + dex_mod + ab)
            dmg = w[:damage] + dex_mod_s
            s, a = w[:shock]
            sho = "%d%s AC %d" % [ s, sgn(str_mod), a ]
            v = "%#{nwidth}s DEX  att %s  dmg %s  shock %#{swidth}s" % [
              nic, att, dmg, sho ]
            t << [ { value: v, colspan: 4 } ]
          end
        end
      end
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

