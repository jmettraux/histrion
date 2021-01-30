
module Creagen

  class << self

    def generate

      p ARGV

      c = Creagen::Creature.new

      c.background =
        YAML.load_file(File.join(__dir__, 'backgrounds.yaml'))
          .shuffle(random: c.rnd)
          .first

      p c
    end
  end
end
