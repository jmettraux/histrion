
module Creagen

  class << self

    def generate

      #p ARGV

      make_character
    end

    def make_character

      c = Creagen::Character.new

      c.background =
        YAML.load_file(File.join(__dir__, 'backgrounds.yaml'))
          .shuffle(random: c.rnd)
          .first

      c.pick_a_skill

      c
    end
  end
end
