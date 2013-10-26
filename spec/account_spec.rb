require 'spec_helper'

describe Keepr::Account do
  before :each do
    Keepr::Journal.create! :date => Date.yesterday,
                           :keepr_postings_attributes => [
                             { :keepr_account => skr03(1000), :amount => 20, :side => 'debit' },
                             { :keepr_account => skr03(1200), :amount => 20, :side => 'credit' }
                            ]

    Keepr::Journal.create! :date => Date.yesterday,
                           :keepr_postings_attributes => [
                             { :keepr_account => skr03(1000), :amount =>  10, :side => 'credit' },
                             { :keepr_account => skr03(1200), :amount =>  10, :side => 'debit' },
                            ]

    Keepr::Journal.create! :date => Date.today,
                           :keepr_postings_attributes => [
                             { :keepr_account => skr03(1000), :amount => 200, :side => 'debit' },
                             { :keepr_account => skr03(1200), :amount => 200, :side => 'credit' }
                            ]

    Keepr::Journal.create! :date => Date.today,
                           :keepr_postings_attributes => [
                             { :keepr_account => skr03(1000), :amount => 100, :side => 'credit' },
                             { :keepr_account => skr03(1200), :amount => 100, :side => 'debit' },
                            ]
  end

  describe :balance do
    it 'should calc total' do
      skr03(1000).balance.should ==  110
      skr03(1200).balance.should == -110
    end

    it 'should calc total for a given date (including)' do
      skr03(1000).balance(Date.today).should ==  110
      skr03(1200).balance(Date.today).should == -110
    end

    it 'should calc total for a given date (excluding)' do
      skr03(1000).balance(Date.yesterday).should == 10
      skr03(1200).balance(Date.yesterday).should == -10
    end
  end

  describe :with_balance do
    it 'should work without date' do
      account1, account2 = Keepr::Account.with_balance

      account1.number.should == 1000
      account1.balance.should == 110
      account2.number.should == 1200
      account2.balance.should == -110
    end

    it 'should work with date (including)' do
      account1, account2 = Keepr::Account.with_balance(Date.today)

      account1.number.should == 1000
      account1.balance.should == 110
      account2.number.should == 1200
      account2.balance.should == -110
    end

    it 'should work with date (excluding)' do
      account1, account2 = Keepr::Account.with_balance(Date.yesterday)

      account1.number.should == 1000
      account1.balance.should == 10
      account2.number.should == 1200
      account2.balance.should == -10
    end

    it 'should not allow calling #balance with date' do
      account1, account2 = Keepr::Account.with_balance(Date.yesterday)

      lambda { account1.balance(Date.today) }.should raise_error(ArgumentError)
    end
  end
end
