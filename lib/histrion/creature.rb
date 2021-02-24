
class Histrion::Creature

  PHYSICAL_ATTRIBUTES = %w[ strength constitution dexterity ]
  MENTAL_ATTRIBUTES = %w[ intelligence wisdom charisma ]

  attr_accessor :name

  attr_accessor :strength, :constitution, :dexterity
  attr_accessor :intelligence, :wisdom, :charisma

  attr_writer :morale

  attr_accessor :appearance

  attr_reader :hp

  attr_reader :skills, :weapons, :spells

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

  def rnd; @opts.rnd; end

  def modifiers
    { strength: str_mod, constitution: con_mod, dexterity: dex_mod,
      intelligence: int_mod, wisdom: wis_mod, charisma: cha_mod }
  end
  def mods
    { str: str_mod, con: con_mod, dex: dex_mod,
      int: int_mod, wis: wis_mod, cha: cha_mod }
  end

  def initialize(opts)

    @opts = opts

    dice = Histrion::Dice.new('3d6')

    self.str = dice.roll
    self.con = dice.roll
    self.dex = dice.roll
    self.int = dice.roll
    self.wis = dice.roll
    self.cha = dice.roll

    @skills = {}
    @weapons = []
  end

  def hd_i

    @hd.match(/^(\d+)d/)[1].to_i
  end

  def morale

    @morale || 6
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

  def magic; @skills['Magic'] || -1; end

  def wp

    (1 + [ 1, int_mod, wis_mod, cha_mod ].max) * level
  end

  def to_table(opts={})

    Terminal::Table.new do |t|

      t.style = {
        width: 82,
        border_left: false, border_right: false,
        border_i: '.' }

      combat_skills =
        [ "#{@opts.lsn('Stab')}-#{stab}",
          "#{@opts.lsn('Shoot')}-#{shoot}",
          "#{@opts.lsn('Punch')}-#{punch}" ]
            .reject { |e| e.match(/[a-z]--2$/) }
      combat_skills << nil if combat_skills.any?

      m = @skills['Magic']
      magic_skills = m ? [ "#{@opts.lsn('Magic')}-#{m}", nil ] : []

      left_skills =
        combat_skills +
        magic_skills
      right_skills =
        (@skills.keys - @opts.combat_skills - @opts.magic_skills)
          .sort
          .map { |k| "#{@opts.lsn(k)}-#{@skills[k]}" }
      skills =
        left_skills + right_skills
      mxw =
        @opts.skills.inject(0) { |l, e| [ l, (e || '').size ].max } + 2
      lmin =
        magic_skills.any? ? 8 : 7
      l2 =
        [ lmin, left_skills.length, (skills.length.to_f * 0.5).floor ].max
      sks0, sks1 =
        skills[0, l2], skills[l2 + 1..-1]
      skills =
        skills[0, l2].zip(skills[l2..-1] || [])
          .collect { |x| "%-#{mxw}s  %-#{mxw}s" % x }

      hp_col = []; w = 15
      hp_col << ("  %#{w}s" % "HP #{hp}")
      hp_col << ("  %#{w}s" % "WP #{wp}") if @skills['Magic']
      hp_col << ("  %-#{w}s" % "Ini #{dex_mod_s}")
      hp_col << ("  %#{w}s" % "naked AC #{naked_ac}")
      hp_col << ("  %#{w}s" % "AC #{ac}")
      hp_col << ("  %#{w}s" % "shield AC #{shield_ac}")
      hp_col << ("  %-#{w}s" % "Att #{sgn(ab)}")
      hp_col << ("  %#{w}s" % "Morale #{morale}")
        #
        # :-(

      n = (name || '').capitalize
      n = "#{n} #{@nick}" if @nick
      n = n[0, 39]

      t << [
        { value: n, colspan: 2 },
        background,
        "#{klass} #{level}" ]

      if appearance
        a = appearance
          .collect { |k, v| v ? (k.to_s.match(/^_/) ? v : "#{v} #{k}") : nil }
          .compact
          .join(', ')
        t << :separator
        t << [ { value: a, colspan: 4 } ]
      end

      t << :separator

      ml = Histrion::Mline.new(58)
      @foci.each do |k, v|
        ml << ', ' if ml.any?
        ml << "#{k}#{v > 1 ? " #{v}" : ''}"
      end

      t << [
        { value: ml.to_s, colspan: 3 },
        'Mov ' + FeetExpander.expand('30 feet') ] #'30ft_9m_6sq_t' ]

      t << :separator

      t << [
        '',
        { value: "STR  #{str_s} (#{str_mod_s})", alignment: :center },
        skills[0],
        hp_col[0] ]
      t << [
        rig("Physical #{phy_save}"),
        { value: "CON  #{con_s} (#{con_mod_s})", alignment: :center },
        skills[1],
        hp_col[1] ]
      t << [
        '',
        { value: "DEX  #{dex_s} (#{dex_mod_s})", alignment: :center },
        skills[2],
        hp_col[2] ]
      t << [
        rig("Evasion #{eva_save}"),
        { value: "INT  #{int_s} (#{int_mod_s})", alignment: :center },
        skills[3],
        hp_col[3] ]
      t << [
        '',
        { value: "WIS  #{wis_s} (#{wis_mod_s})", alignment: :center },
        skills[4],
        hp_col[4] ]
      t << [
        rig("Mental #{men_save}"),
        { value: "CHA  #{cha_s} (#{cha_mod_s})", alignment: :center },
        skills[5],
        hp_col[5] ]
      t << [
        rig("Luck #{luk_save}"),
        '',
        (skills[6..-1] || []).join("\n"),
        (hp_col[6..-1] || []).join("\n") ]

      t << :separator

      nwidth = 9 # weapon name width

      mws = []
      rws = []
        #
      weapons.each do |w|
        if w[:attributes].include?('strength')
          nic =
            w[:nick][0, nwidth]
          att =
            sgn(stab + str_mod + ab)
          dmg =
            w[:damage].is_a?(Proc) ?
            w[:damage].call :
            w[:damage] + str_mod_s
          s, a = w[:shock]
          sho = s ? "%d%s AC %d" % [ s, sgn(str_mod), a ] : '-'
          v = "%#{nwidth}s  STR  %s  dmg %s  shk %9s" % [
            nic, att, dmg, sho ]
          mws << [ { value: v, colspan: 4 } ]
        end
        if w[:attributes].include?('dexterity')
          if r = w[:range]
            r0, r1 = r.collect { |e| FeetExpander.exp(e) }
            r1 = ' ' + r1 if r1.match(/^\d\df/)
            nic = w[:nick][0, nwidth]
            att0 = shoot + dex_mod + ab
            att1 = att0 - 2
            dmg = w[:damage] + dex_mod_s
            v = "%#{nwidth + 2}s  DEX  %s ->%-18s %s ->%-19s  dmg %s" % [
              nic, sgn(att0), r0, sgn(att1), r1, dmg ]
            rws << [ { value: v, colspan: 4 } ]
          else
            nic =
              w[:nick][0, nwidth]
            att =
              sgn(stab + dex_mod + ab)
            dmg =
              w[:damage].is_a?(Proc) ?
              w[:damage].call :
              w[:damage] + dex_mod_s
            s, a = w[:shock]
            sho = s ? "%d%s AC %d" % [ s, sgn(str_mod), a ] : '-'
            v = "%#{nwidth}s  DEX  %s  dmg %s  shk %9s" % [
              nic, att, dmg, sho ]
            mws << [ { value: v, colspan: 4 } ]
          end
        end
      end
        #
      mws.each { |w| t << w }
      rws.each { |w| t << w }

      if @spells && @spells.any?

        t << :separator

        spells =
          ('spells: ' + @spells.collect { |s| s[:name] }.join(', '))
            .split(/\s/)
            .inject([ [] ]) { |a, w|
              ll = a.last.collect(&:length).sum + a.last.length - 1
              if ll + 1 + w.length < 79
                a.last << w
              else
                a << [ ' ' * 'spells:'.length, w ]
              end
              a }
            .collect { |l| l.join(' ') }
            .join("\n")

        t << [ { value: spells, colspan: 4 } ]
      end

      if @goods && @goods.any?

        t << :separator

        goods = "goods:  #{@goods.join(', ')}"[0, 78]

        t << [ { value: goods, colspan: 4 } ]
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

  def lft(v); { value: v, alignment: :left }; end
  def rig(v); { value: v, alignment: :right }; end
  def cnt(v); { value: v, alignment: :center }; end

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

    inc_skill(@opts.random_skill)
  end

  def apply_background_roll_learning(b)

    case l = pick(b[:learning])
    when /^Any Combat$/i then grow_combat_skill
    when /^Any Skill$/i then grow_any_skill
    else inc_skill(l)
    end
  end

  def inc_skill(s)

    s1 = @opts.normalize_skill_name(s)

    l = @skills[s1] || -1

    return false if l > 0

    @skills[s1] = l + 1

    add_punch_weapon_if_necessary

    true
  end

  def add_punch_weapon_if_necessary

    return if ! @skills['Punch']

    wp = @weapons.find { |w| w[:name] == 'Punch' }
    return if wp && ! wp[:focus]

    @weapons.reject! { |w| w[:name] == 'Punch' }

    @weapons << {
      name: 'Punch', nick: 'Punch', damage: lambda { "1d2+#{punch}" },
      attributes: %w[ strength dexterity ] }
  end

  def pick(*as)

    as
      .inject([]) { |r, a| r.concat(a) }
      .shuffle(random: @opts.rnd)
      .first
  end
end

