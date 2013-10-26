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
      account1, account2 = Keepr::Account.with_balance.having('preloaded_sum_amount <> 0')

      account1.number.should == 1000
      account1.balance.should == 110
      account2.number.should == 1200
      account2.balance.should == -110
    end
  end
end

describe Keepr::Account, 'with subaccounts' do
  before :each do
    Keepr::Account.create! :number => 10000, :kind => 'Asset', :name => 'Diverse Debitoren', :parent => skr03(1400)

    Keepr::Journal.create! :date => Date.yesterday,
                           :keepr_postings_attributes => [
                             { :keepr_account => skr03(10000), :amount => 20, :side => 'debit' },
                             { :keepr_account => skr03( 8400), :amount => 20, :side => 'credit' }
                            ]
  end

  describe :keepr_postings do
    it 'should include postings from descendant accounts' do
      skr03(1400).should have(1).keepr_postings
      skr03(10000).should have(1).keepr_postings
    end
  end

  describe :balance do
    it 'should include postings from descendant accounts' do
      skr03(1400).balance.should == 20
      skr03(10000).balance.should == 20
    end

    it 'should include postings from descendant accounts with date given' do
      skr03(1400).balance(Date.today).should == 20
      skr03(10000).balance(Date.today).should == 20
    end
  end

  describe :with_balance do
    it 'should calc balance' do
      Keepr::Account.with_balance.
                     select { |a| (a.preloaded_sum_amount || 0) != 0 }.
                     map { |a| [a.number, a.preloaded_sum_amount] }.
                     should == [[8400, -20], [10000, 20]]
    end
  end

  describe :merged_with_balance do
    it 'should calc merged balance' do
      Keepr::Account.merged_with_balance.
                     select { |a| (a.preloaded_sum_amount || 0) != 0 }.
                     map { |a| [a.number, a.preloaded_sum_amount] }.
                     should == [[1400, 20], [8400, -20]]
    end
  end
end
