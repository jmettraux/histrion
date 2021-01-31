
#module AacDieHard
#  # Gain an extra 2 maximum hit points per level.
#  def hp
#    super + (2 * level)
#  end
#end
#module AacMoreProudTheSpirit
#  # 2 additional maximum hit points per level.
#  def hp
#    super + (2 * level)
#  end
#end
module AacTwoExtraHitPoints
  def hp
    super + (2 * level)
  end
end

module AacImperviousDefense
  # Innate Armor Class of 15 plus half the character level, rounded up.
  def naked_ac
    15 + (level.to_f * 0.5).ceil + dex_mod
  end
end

module AacOakenHide
  # Base armor class equal to fifteen plus half your level, rounded down,
  # as if wearing armor.
  # Shields brings their usual benefit, but armor inferior to this focus armor
  # class will do no good.
  def naked_ac
    15 + (level.to_f * 0.5).floor + dex_mod
  end
end

AacPolymath = lambda do |character|
  character.send(:grow_any_skill)
end

AacWrestler = lambda do |character|
  # The character unarmed Punch attack does a base of 1d6 damage and
  # its Shock is 1 / AC 15. +1 on all grappling skill checks
  character.weapons << {
    name: 'Punch', nick: 'Punch', attributes: %w[ strength ],
    damage: '1d6', shock: [ 1, 15 ] }
end

[
  { name: 'Alert', skills: %w[ Notice ] },
  { name: 'As Our Power Lessens' },
  { name: 'Authority', skills: %w[ Lead ] },
  { name: 'Bringer of Endings', skills: %w[ Stab ] },
  { name: 'Close Combatant', skills: %w[ Stab ] },
  { name: 'Connected', skills: %w[ Connect ] },
  { name: 'Cultured', skills: %w[ Connect ] },
  { name: 'Die Hard', module: AacTwoExtraHitPoints },
  { name: 'Harder Be Purpose' },
  { name: "Healer's Hand", skills: %w[ Heal ] },
  { name: 'Impervious Defense', module: AacImperviousDefense },
  { name: 'Lucky' },
  { name: 'Manslayer', skills: [ %w[ Stab Punch ] ] },
  { name: 'More Proud the Spirit', module: AacTwoExtraHitPoints },
  { name: 'Oaken Hide', module: AacOakenHide },
  { name: 'Polymath', lambda: AacPolymath },
  { name: 'Rider', skills: %w[ Ride ] },
  { name: 'Scop-wise', skills: %w[ Perform ] },
  { name: 'Specialist', skills: [ 'Any Skill' ] },
  { name: 'Strongbow', skills: %w[ Shoot ] },
  { name: 'Wrestler', lambda: AacWrestler },
]

