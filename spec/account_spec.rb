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
      before :all do
        Keepr::Journal.create! :subject          => 'Get cash from bank account',
                               :date => Date.today,
                               :keepr_postings_attributes => [
                                 { :keepr_account => skr03(1000), :amount =>  200 },
                                 { :keepr_account => skr03(1200), :amount => -200 }
                                ]

        Keepr::Journal.create! :subject          => 'Bring cash to bank account',
                               :date => Date.today,
                               :keepr_postings_attributes => [
                                 { :keepr_account => skr03(1000), :amount => -100 },
                                 { :keepr_account => skr03(1200), :amount =>  100 },
                                ]
      end

      it 'should calc total' do
        skr03(1000).balance.should ==  100
        skr03(1200).balance.should == -100
      end

      it 'should calc total for a given date (including)' do
        skr03(1000).balance(Date.today).should ==  100
        skr03(1200).balance(Date.today).should == -100
      end

      it 'should calc total for a given date (excluding)' do
        skr03(1000).balance(Date.yesterday).should == 0
        skr03(1200).balance(Date.yesterday).should == 0
      end
    end
  end
end
