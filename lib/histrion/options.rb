
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

    def skill_map

      @skill_map ||=
        YAML.load_file(find_path(Dir[path('*_skills.yaml')]))
          .inject({}) { |h, (k, v)| h[k] = v || k; h }
    end

    def skill_pam

      @skill_pam ||=
        skill_map
          .inject({}) { |h, (k, v)| h[v] = k; h }
    end

    def normalize_skill_name(n)

      skill_map[n] ||
      (skill_map.values.include?(n) ? n : nil) ||
      fail(ArgumentError.new("unknown skill name #{n.inspect}"))
    end

    def localize_skill_name(n)

      skill_pam[n] ||
      n
    end
    alias lsn localize_skill_name

    def skills

      skill_map.values
    end

    COMBAT_SKILLS = %w[ Stab Shoot Punch ]
    MAGIC_SKILLS = %w[ Magic ]

    def combat_skills

      COMBAT_SKILLS
    end

    def magic_skills

      MAGIC_SKILLS
    end

    def non_combat_skills

      skills - COMBAT_SKILLS
    end

    def skills_without_magic

      skills - %w[ Magic ]
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

    def path(fname); File.join('var', fname); end
  end
end

