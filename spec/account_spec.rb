require 'spec_helper'

describe Keepr::Account do
  let!(:account_1000) { FactoryGirl.create(:account, :number => 1000) }
  let!(:account_1200) { FactoryGirl.create(:account, :number => 1200) }

  before :each do
    Keepr::Journal.create! :date => Date.yesterday,
                           :keepr_postings_attributes => [
                             { :keepr_account => account_1000, :amount => 20, :side => 'debit' },
                             { :keepr_account => account_1200, :amount => 20, :side => 'credit' }
                            ]

    Keepr::Journal.create! :date => Date.yesterday,
                           :keepr_postings_attributes => [
                             { :keepr_account => account_1000, :amount =>  10, :side => 'credit' },
                             { :keepr_account => account_1200, :amount =>  10, :side => 'debit' },
                            ]

    Keepr::Journal.create! :date => Date.today,
                           :keepr_postings_attributes => [
                             { :keepr_account => account_1000, :amount => 200, :side => 'debit' },
                             { :keepr_account => account_1200, :amount => 200, :side => 'credit' }
                            ]

    Keepr::Journal.create! :date => Date.today,
                           :keepr_postings_attributes => [
                             { :keepr_account => account_1000, :amount => 100, :side => 'credit' },
                             { :keepr_account => account_1200, :amount => 100, :side => 'debit' },
                            ]
  end

  describe :balance do
    it 'should calc total' do
      expect(account_1000.balance).to eq(110)
      expect(account_1200.balance).to eq(-110)
    end

    it 'should calc total for a given date (including)' do
      expect(account_1000.balance(Date.today)).to eq(110)
      expect(account_1200.balance(Date.today)).to eq(-110)
    end

    it 'should calc total for a given date (excluding)' do
      expect(account_1000.balance(Date.yesterday)).to eq(10)
      expect(account_1200.balance(Date.yesterday)).to eq(-10)
    end
  end

  describe :with_balance do
    it 'should work without date' do
      account1, account2 = Keepr::Account.with_balance.having('preloaded_sum_amount <> 0')

      expect(account1.number).to eq(1000)
      expect(account1.balance).to eq(110)
      expect(account2.number).to eq(1200)
      expect(account2.balance).to eq(-110)
    end
  end
end

describe Keepr::Account, 'with subaccounts' do
  let!(:account_1400) { FactoryGirl.create(:account, :number => 1400) }
  let!(:account_10000) { FactoryGirl.create(:account, :number => 10000, :parent => account_1400) }
  let!(:account_8400) { FactoryGirl.create(:account, :number => 8400) }

  before :each do
    Keepr::Journal.create! :date => Date.yesterday,
                           :keepr_postings_attributes => [
                             { :keepr_account => account_10000, :amount => 20, :side => 'debit' },
                             { :keepr_account => account_8400, :amount => 20, :side => 'credit' }
                            ]
  end

  describe :keepr_postings do
    it 'should include postings from descendant accounts' do
      expect(account_1400.keepr_postings.size).to eq(1)
      expect(account_10000.keepr_postings.size).to eq(1)
    end
  end

  describe :balance do
    it 'should include postings from descendant accounts' do
      expect(account_1400.reload.balance).to eq(20)
      expect(account_10000.reload.balance).to eq(20)
    end

    it 'should include postings from descendant accounts with date given' do
      expect(account_1400.balance(Date.today)).to eq(20)
      expect(account_10000.balance(Date.today)).to eq(20)
    end
  end

  describe :with_balance do
    it 'should calc balance' do
      expect(Keepr::Account.with_balance.
                     select { |a| (a.preloaded_sum_amount || 0) != 0 }.
                     map { |a| [a.number, a.preloaded_sum_amount] }).
                     to eq([[8400, -20], [10000, 20]])
    end
  end

  describe :merged_with_balance do
    it 'should calc merged balance' do
      expect(Keepr::Account.merged_with_balance.
                     select { |a| (a.preloaded_sum_amount || 0) != 0 }.
                     map { |a| [a.number, a.preloaded_sum_amount] }).
                     to eq([[1400, 20], [8400, -20]])
    end
  end
end
