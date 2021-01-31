
module Creagen

  class << self

    def generate

      #p ARGV

      make_character
    end

    def make_character

      load(File.join(__dir__, 'aac_foci.rb'))

      klasses = YAML.load_file(File.join(__dir__, 'aac_classes.yaml'))

      c = Creagen::Character.new

      c.background =
        YAML.load_file(File.join(__dir__, 'aac_backgrounds.yaml'))
          .shuffle(random: c.rnd)
          .first

      c.name =
        File.readlines(File.join(__dir__, 'norse_male_names.txt'))
          .select { |l| l.length > 0 }
          .shuffle(random: c.rnd)
          .first

      c.klass =
        klasses
          .find { |k|
            att = k[:attribute]
            mod = att ? c.mod(att) : -3
            mod > 0 } ||
        klasses
          .shuffle(random: c.rnd)
          .first

      c.pick_a_skill

      c
    end
  end
end
