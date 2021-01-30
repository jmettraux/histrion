
#
# Specifying creagen
#
# Sat Jan 30 15:05:05 JST 2021
#

require 'spec_helper'


describe Creagen::Dice do

  describe '.parse' do

    {

      'd6' => [ [ nil, 6 ] ],
      'd10-10' => [ [ nil, 10 ], -10 ],
      '3d6-1' => [ [ 3, 6 ], -1 ],

    }.each do |k, v|

      it "parses #{k.inspect}" do

        expect(Creagen::Dice.parse(k)).to eq(v)
      end
    end
  end

  describe '#roll' do

    {

      'd6' => [ 1, 6 ],
      '2d6' => [ 2, 12 ],
      '2d6-10' => [ 2 - 10, 12 - 10 ],

    }.each do |k, (a, b)|

      it "rolls #{k.inspect}" do

        d = Creagen::Dice.new(k)

        1_024.times { expect(d.roll).to be_between(a, b) }
      end
    end
  end
end

