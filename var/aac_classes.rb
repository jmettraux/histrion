
AAC_SPELLS =
  (File.readlines('var/aac_spells.md') rescue [])
    .inject([]) { |a, l|
      if m = l.match(/^## (.+)/)
        n = m[1]
        c, f = m[1].split(/\s/)
        a << { name: n, colour: c, form: f }
      end
      a }
AAC_COLOURS =
  AAC_SPELLS.collect { |s| s[:colour] }.uniq
AAC_FORMS =
  AAC_SPELLS.collect { |s| s[:form] }.uniq

AacPickSpells =
  lambda do |creature|

    2.times do

      if creature.spells.count < 2

        creature.spells <<
          AAC_SPELLS.shuffle(random: creature.rnd).first

      else

        facets = creature.spells
          .inject([]) { |a, s| a << s[:colour]; a << s[:form]; a }
          .uniq
        facet = facets
          .shuffle(random: creature.rnd).first

        spells = AAC_SPELLS.shuffle(random: creature.rnd)

        spell = spells
          .find { |s|
            ! creature.spells.include?(s) &&
            (s[:colour] == facet || s[:form] == facet) }
        creature.spells << spell if spell
      end
    end

    creature.spells.sort_by! { |s| s[:name] }
  end

[
  { name: 'Fighter',
    attribute: 'strength',
    skill: 'Stab',
    levels: [
      { hp: '1d6+2', attack: 1, foci: 2 },
      { hp: '2d6+4', attack: 2, foci: 1 },
      { hp: '3d6+6', attack: 3 },
      { hp: '4d6+8', attack: 4 },
      { hp: '5d6+10', attack: 5, foci: 1 },
      { hp: '6d6+12', attack: 6 },
      { hp: '7d6+14', attack: 7, foci: 1 },
      { hp: '8d6+16', attack: 8 },
      { hp: '9d6+18', attack: 9 },
      { hp: '10d6+20', attack: 10, foci: 1 }],
    weapons: [ 'Spear', [ 'Axe', 'Seax' ], [ 'Bow', nil ] ] },

  { name: 'Expert',
    attribute: nil,
    skill: nil,
    levels: [
      { hp: '1d6', attack: 0, foci: 2 },
      { hp: '2d6', attack: 1, foci: 1 },
      { hp: '3d6', attack: 1 },
      { hp: '4d6', attack: 2 },
      { hp: '5d6', attack: 2, foci: 1 },
      { hp: '6d6', attack: 3 },
      { hp: '7d6', attack: 3, foci: 1 },
      { hp: '8d6', attack: 4 },
      { hp: '9d6', attack: 4 },
      { hp: '10d6', attack: 5, foci: 1 } ],
    weapons: [ [ 'Club', 'Staff', 'Bow' ], [ 'Seax', 'Knife' ] ] },

  { name: 'Weaver',
    attribute: 'intelligence',
    skill: 'Magic',
    levels: [
      { hp: '1d6-1', attack: 0, foci: 1 },
      { hp: '2d6-2', attack: 0, foci: 1 },
      { hp: '3d6-3', attack: 1 },
      { hp: '4d6-4', attack: 1 },
      { hp: '5d6-5', attack: 2, foci: 1 },
      { hp: '6d6-6', attack: 2 },
      { hp: '7d6-7', attack: 3, foci: 1 },
      { hp: '8d6-8', attack: 3 },
      { hp: '9d6-9', attack: 3 },
      { hp: '10d6-10', attack: 4, foci: 1 } ],
    weapons: [ [ 'Staff', 'Bow' ], [ 'Seax', 'Knife' ] ],
    spells: AacPickSpells },
]

