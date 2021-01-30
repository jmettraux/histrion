
class Creagen::Creature

  attr_accessor :strength, :constitution, :dexterity
  attr_accessor :intelligence, :wisdom, :charisma

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
end

