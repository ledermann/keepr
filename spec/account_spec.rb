require 'spec_helper'

describe Keepr::Account do
  describe :balance do
    context 'without journals' do
      it 'should be zero' do
        skr03(1000).balance.should be_zero
        skr03(1200).balance.should be_zero
      end
    end

    context 'with journals' do
      before :each do
        Keepr::Journal.create! :subject          => 'Get cash from bank account',
                               :postings_attributes => [
                                 { :account => skr03(1000), :amount =>  200 },
                                 { :account => skr03(1200), :amount => -200 }
                                ]

        Keepr::Journal.create! :subject          => 'Bring cash to bank account',
                               :postings_attributes => [
                                 { :account => skr03(1000), :amount => -100 },
                                 { :account => skr03(1200), :amount =>  100 },
                                ]
      end

      it 'should calc total' do
        skr03(1000).balance.should ==  100
        skr03(1200).balance.should == -100
      end
    end
  end
end
