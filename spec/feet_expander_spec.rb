
#
# Specifying 5town
#
# Thu Jan 14 18:58:27 JST 2021
#

require 'spec_helper'


describe FeetExpander do

  describe '.expand' do

    {

      "reach 5 ft., " =>
        "reach 5ft_1.5m_1sq, ",

      "**Speed** 40 ft." =>
        "**Speed** 40ft_12m_8sq_F",

      "**Move** 0 ft., fly 60 ft. (hover)" =>
        "**Move** 0ft, fly 60ft_18m_12sq_tt (hover)",

      "+4 to hit, range 80/320 ft., one" =>
        "+4 to hit, range 80ft_24m_16sq_FF / 320ft_96m_64sq_8F, one",

      "reach 5 ft. or range 20/60 ft., one" =>
        "reach 5ft_1.5m_1sq or range 20ft_6m_4sq_t-2 / 60ft_18m_12sq_tt, one",

      '500 feet' =>
        '500ft_150m_100sq_11Ftt',

      '5ft' => '5ft_1.5m_1sq',
      '10ft' => '10ft_3m_2sq',
      '15ft' => '15ft_4.5m_3sq',
      '20ft' => '20ft_6m_4sq_t-2',
      '25ft' => '25ft_7.5m_5sq_t-1',
      '30ft' => '30ft_9m_6sq_t',
      '35ft' => '35ft_10.5m_7sq_F-1',
      '40ft' => '40ft_12m_8sq_F',
      '45ft' => '45ft_13.5m_9sq_F+1',
      '50ft' => '50ft_15m_10sq_F+2',
      '55ft' => '55ft_16.5m_11sq_F+3',
      '60ft' => '60ft_18m_12sq_tt',
      '65ft' => '65ft_19.5m_13sq_Ft-1',
      '70ft' => '70ft_21m_14sq_Ft',
      '80ft' => '80ft_24m_16sq_FF',
      '90ft' => '90ft_27m_18sq_ttt',
      '95ft' => '95ft_28.5m_19sq_Ftt-1',
      '100ft' => '100ft_30m_20sq_Ftt',
      '105ft' => '105ft_31.5m_21sq_FFt-1',
      '110ft' => '110ft_33m_22sq_FFt',
      '120ft' => '120ft_36m_24sq_FFF',
      '125ft' => '125ft_37.5m_25sq_Fttt-1',
      '130ft' => '130ft_39m_26sq_Fttt',
      '135ft' => '135ft_40.5m_27sq_FFtt-1',
      '140ft' => '140ft_42m_28sq_FFtt',
      '145ft' => '145ft_43.5m_29sq_FFFt-1',
      '150ft' => '150ft_45m_30sq_FFFt',
      '160ft' => '160ft_48m_32sq_4F',
      '165ft' => '165ft_49.5m_33sq_FFttt-1',
      '320ft' => '320ft_96m_64sq_8F',
      '400ft' => '400ft_120m_80sq_10F',
      '600ft' => '600ft_180m_120sq_15F',

      '245ft' => '245ft_73.5m_49sq_4Fttt-1',
      '295ft' => '295ft_88.5m_59sq_6Ftt-1',

    }.each do |k, v|

      it "turns #{k.inspect} into #{v.inspect}" do

        expect(FeetExpander.expand(k)).to eq(v)
      end
    end
  end
end

