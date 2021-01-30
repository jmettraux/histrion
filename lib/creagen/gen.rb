
module Creagen

  class << self

    def generate

      p ARGV

      c = Creagen::Creature.new
      c.str = roll('3d6')
      c.con = roll('3d6')
      c.dex = roll('3d6')
      c.int = roll('3d6')
      c.wis = roll('3d6')
      c.cha = roll('3d6')

      p c
    end
  end
end
