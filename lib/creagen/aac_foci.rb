
module AacDieHard
end

module AacImperviousDefense
end

module AacMoreProudTheSpirit
end

module AacOakenHide
end

AacPolymath =
  lambda do |character|
    character.send(:grow_any_skill)
  end

module AacWrestler
end

FOCI = [
  { name: 'Alert', skills: %w[ Notice ] },
  { name: 'As Our Power Lessens' },
  { name: 'Authority', skills: %w[ Lead ] },
  { name: 'Bringer of Endings', skills: %w[ Stab ] },
  { name: 'Close Combatant', skills: %w[ Stab ] },
  { name: 'Connected', skills: %w[ Connect ] },
  { name: 'Cultured', skills: %w[ Connect ] },
  { name: 'Die Hard', module: AacDieHard },
  { name: 'Harder Be Purpose' },
  { name: "Healer's Hand", skills: %w[ Heal ] },
  { name: 'Impervious Defense', module: AacImperviousDefense },
  { name: 'Lucky' },
  { name: 'Manslayer', skills: [ %w[ Stab Punch ] ] },
  { name: 'More Proud the Spirit', module: AacMoreProudTheSpirit },
  { name: 'Oaken Hide', module: AacOakenHide },
  { name: 'Polymath', lambda: AacPolymath },
  { name: 'Rider', skills: %w[ Ride ] },
  { name: 'Scop-wise', skills: %w[ Perform ] },
  { name: 'Specialist', skills: [ 'Any Skill' ] },
  { name: 'Strongbow', skills: %w[ Shoot ] },
  { name: 'Wrestler', module: AacWrestler },
    ]

