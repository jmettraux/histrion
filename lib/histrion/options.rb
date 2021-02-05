
module Histrion

  class Options

    attr_reader :rnd
    attr_reader :count, :pluses, :minuses
    attr_reader :foci, :weapons, :classes, :backgrounds, :names

    def initialize

      @rnd = Random.new

      @count = 1
      @pluses = []
      @minuses = []
      @strings = []
      @levels = [ 1 ]

      ARGV.each do |a|
        case a
        when /^\d+$/
          @count = a.to_i
        when /^(\d+)-(\d+)$/
          @levels = ($1.to_i..$2.to_i).to_a
        when /^\+(.+)$/
          @pluses << $1.downcase
        when /^-(.+)$/
          @minuses << $1.downcase
        else
          @strings << a.downcase
        end
      end
    end

    def stab_skill_name; skills[0]; end
    def shoot_skill_name; skills[1]; end
    def punch_skill_name; skills[2]; end
    def magic_skill_name; skills[3]; end

    def skills

      @skills ||=
        File.readlines(find_path(Dir[path('*_skills.txt')]))
          .collect(&:strip)
          .select { |l|l.length > 0 && l[0, 1] != '#' }
    end

    def combat_skills

      skills[0, 4]
    end

    def non_combat_skills

      skills[4..-1]
    end

    def skills_without_magic

      skills - [ magic_skill_name ]
    end

    def random_skill

      skills
        .shuffle(random: @rnd)
        .first
    end

    def random_non_combat_skill

      non_combat_skills
        .shuffle(random: @rnd)
        .first
    end

    def random_background

      YAML.load_file(find_path(Dir[path('*_backgrounds.yaml')]))
        .shuffle(random: @rnd)
        .first
    end

    def random_name

      File.readlines(find_path(Dir[path('*_male_names.txt')]))
        .collect { |e| e.strip.capitalize }
        .select { |l| l.length > 0 && l[0, 1] != '#' }
        .shuffle(random: @rnd)
        .first
    end

    def random_place_name

      File.readlines(find_path(Dir[path('*_place_names.txt')]))
        .collect { |e| e.strip.capitalize }
        .select { |l| l.length > 0 && l[0, 1] != '#' }
        .shuffle(random: @rnd)
        .first
    end

    def random_appearance

      @appearance ||=
        YAML.load_file(find_path(Dir[path('*_male_appearance.yaml')]))

      @appearance.inject({}) { |h, (k, v)|
        h[k] = v.shuffle(random: @rnd).find { |e| ! @minuses.include?(e) }
        h }
    end

    def klasses

      @klasses ||=
        YAML.load_file(find_path(Dir[path('*_classes.yaml')]))
          .reject { |c| @minuses.include?(c[:name].downcase) }
    end

    def foci

      @foci ||=
        Kernel.eval(File.read(find_path(Dir[path('*_foci.rb')])))
    end

    def weapons

      @weapons ||=
        YAML.load_file(find_path(Dir[path('*_weapons.yaml')]))
          .reject { |c| @minuses.include?(c[:nick].downcase) }
          .inject({}) { |h, w| h[w[:nick]] = w; h }
    end

    def random_level

      @levels.shuffle(random: @rnd).first
    end

    protected

    def find_path(paths)

      paths = paths.sort
      path = paths
        .find { |pa|
          pfx = File.basename(pa).split('_').first
          @strings.empty? ? true : @strings.include?(pfx) }
      path || paths.first
    end

    def path(fname); File.join(__dir__, fname); end
  end
end

