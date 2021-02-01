
module Creagen

  class Options

    attr_reader :rnd
    attr_reader :count
    attr_reader :foci, :weapons, :classes, :backgrounds, :names

    def initialize

      @rnd = Random.new

      @count = 1
      @minuses = []
      @strings = []

      ARGV.each do |a|
        case a
        when /^\d+/
          @count = a.to_i
        when /^-(.+)$/
          @minuses << $1.downcase
        else
          @strings << a.downcase
        end
      end
    end

    def random_background

      YAML.load_file(find_path(Dir[path('*_backgrounds.yaml')]))
        .shuffle(random: @rnd)
        .first
    end

    def random_name

      File.readlines(find_path(Dir[path('*_male_names.txt')]))
        .collect(&:strip)
        .select { |l| l.length > 0 && l[0, 1] != '#' }
        .shuffle(random: @rnd)
        .first
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

  class << self

    def generate

      opts = Options.new

p opts
      opts.count.times do

        #puts
        puts make_character(opts).to_table
      end
    end

    def make_character(opts)

      c = Creagen::Character.new(opts)

      c.background =
        opts.random_background

      c.name =
        opts.random_name

      c.klass =
        opts.klasses
          .find { |k|
            att = k[:attribute]
            mod = att ? c.mod(att) : -3
            mod > 0 } ||
        opts.klasses
          .shuffle(random: opts.rnd)
          .first

      c.pick_a_skill

      c
    end
  end
end
