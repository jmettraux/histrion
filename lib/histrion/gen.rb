
module Histrion

  class << self

    def generate

      opts = Options.new

      opts.count.times do

        puts
        puts
        puts make_character(opts).to_table
      end
    end

    def make_character(opts)

      c = Histrion::Character.new(opts)

      c.background =
        opts.random_background

      c.appearance = opts.random_appearance \
        unless opts.minuses.include?('appearance')

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

      c.pick_spells

      c.add_nick if Histrion.roll('1d6') > 2

      (opts.random_level - 1)
        .times { c.level_up }

      c
    end
  end
end

