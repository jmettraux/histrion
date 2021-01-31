
module Creagen

  FOCI =
    Kernel.eval(File.read(File.join(__dir__, 'aac_foci.rb')))
  WEAPONS =
    YAML.load_file(File.join(__dir__, 'aac_weapons.yaml'))
      .inject({}) { |h, w| h[w[:nick]] = w; h }

  class << self

    def generate

      count = 1

      ARGV.each do |a|
        if a.match?(/^\d+/)
          count = a.to_i
        end
      end

      count.times do

        #puts
        puts make_character.to_table
      end
    end

    def make_character

      klasses = YAML.load_file(File.join(__dir__, 'aac_classes.yaml'))

      c = Creagen::Character.new

      c.background =
        YAML.load_file(path('aac_backgrounds.yaml'))
          .shuffle(random: c.rnd)
          .first

      c.name =
        File.readlines(path('norse_male_names.txt'))
          .collect(&:strip)
          .select { |l| l.length > 0 && l[0, 1] != '#' }
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

    protected

    def path(fname); File.join(__dir__, fname); end
  end
end
