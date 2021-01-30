
class Creagen::Character < Creagen::Creature

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

  def pick_a_skill

    while grow_any_skill == false; end
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

