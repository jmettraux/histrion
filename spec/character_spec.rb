
#
# Specifying histrion
#
# Sun Feb 28 18:49:18 JST 2021
#

require 'spec_helper'


describe Histrion::Character do

  describe '.to_h' do

    it 'works'
  end

  describe '.from_h' do

    it 'works' do

      h = YAML.load_file('spec/c0.yaml')
      c = Histrion::Character.from_h(h)

      expect(c).to be_a(Histrion::Character)

#File.open('c.txt', 'wb') { |f| f.write(c.to_table.to_s) }
      expect(c.to_table.to_s).to eq(%{
-------------------------------.----------------------------.-------------------
 Nemo                          |                            | Weaver 1
-------------------------------.----------------------------.-------------------
 Healer's Hand                                              | Mov 30ft_9m_6sq_t
----------------.--------------.----------------------------.-------------------
                | STR  12 (+0) | Magic-0                    |              HP 1
    Physical 15 | CON  10 (+0) |                            |              WP 2
                | DEX  11 (+0) | Connect-0                  |   Ini +0
     Evasion 14 | INT  16 (+1) | Craft-0                    |       naked AC 10
                | WIS   5 (-1) | Heal-0                     |             AC 10
      Mental 15 | CHA  11 (+0) | Trade-0                    |      shield AC 15
        Luck 15 |              |                            |   Att +0          
                |              |                            |         Morale 11
----------------.--------------.----------------------------.-------------------
     Staff  STR  -2  dmg 1d6+0  shk 2+0 AC 13
      Seax  STR  -2  dmg 1d6+0  shk 1+0 AC 15
      Seax  DEX  -2  dmg 1d6+0  shk 1+0 AC 15
--------------------------------------------------------------------------------
      }.strip)
    end
  end

  describe '.load' do

    it 'works' do

      c = Histrion::Character.load('spec/c0.yaml')

      expect(c).to be_a(Histrion::Character)
    end
  end
end

