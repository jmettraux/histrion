
require 'yaml'

puts YAML.dump([
  { name: 'Commoner',
    free: 'Work',
    quick: [
      'Stab', 'Connect' ],
    growth: [
      '+1 Any Att', '+2 Physical', '+2 Mental', 'Exert', 'Any Skill' ],
    learning: [
      'Any Skill', 'Connect', 'Craft', 'Exert', 'Hunt', 'Administer' ] },
  { name: 'Commoner',
    free: 'Work',
    quick: [
      'Stab', 'Connect' ],
    growth: [
      '+1 Any Att', '+2 Physical', '+2 Mental', 'Exert', 'Any Skill' ],
    learning: [
      '' ] },
])

