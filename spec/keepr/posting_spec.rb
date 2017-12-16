require 'spec_helper'

describe Keepr::Posting do
  let!(:account_1000) { FactoryBot.create(:account, number: 1000, kind: :asset) }

  describe 'side/amount' do
    it 'should handle empty object' do
      posting = Keepr::Posting.new
      expect(posting.amount).to be_nil
      expect(posting.side).to be_nil
    end

    it 'should set credit amount' do
      posting = Keepr::Posting.new amount: 10, side: 'credit'

      expect(posting).to be_credit
      expect(posting.amount).to eq(10)
      expect(posting.raw_amount).to eq(-10)
    end

    it 'should set debit amount' do
      posting = Keepr::Posting.new amount: 10, side: 'debit'

      expect(posting).to be_debit
      expect(posting.amount).to eq(10)
      expect(posting.raw_amount).to eq(10)
    end

    it 'should set side and amount in different steps' do
      posting = Keepr::Posting.new

      posting.side = 'credit'
      expect(posting).to be_credit
      expect(posting.amount).to be_nil

      posting.amount = 10
      expect(posting).to be_credit
      expect(posting.amount).to eq(10)
    end

    it 'should change to credit' do
      posting = Keepr::Posting.new amount: 10, side: 'debit'
      posting.side = 'credit'

      expect(posting).to be_credit
      expect(posting.amount).to eq(10)
    end

    it 'should change to debit' do
      posting = Keepr::Posting.new amount: 10, side: 'credit'
      posting.side = 'debit'

      expect(posting).to be_debit
      expect(posting.amount).to eq(10)
    end

    it 'should default to debit' do
      posting = Keepr::Posting.new amount: 10

      expect(posting).to be_debit
      expect(posting.amount).to eq(10)
    end

    it 'should handle string amount' do
      posting = Keepr::Posting.new amount: '0.5'

      expect(posting).to be_debit
      expect(posting.amount).to eq(0.5)
    end

    it 'should recognized saved debit posting' do
      posting = Keepr::Posting.create!(amount: 10, side: 'debit', keepr_account: account_1000, keepr_journal_id: 42)
      posting.reload

      expect(posting).to be_debit
      expect(posting.amount).to eq(10)
    end

    it 'should recognized saved credit posting' do
      posting = Keepr::Posting.create!(amount: 10, side: 'credit', keepr_account: account_1000, keepr_journal_id: 42)
      posting.reload

      expect(posting).to be_credit
      expect(posting.amount).to eq(10)
    end

    it 'should fail for negative amount' do
      expect {
        Keepr::Posting.new(amount: -10)
      }.to raise_error(ArgumentError)
    end

    it 'should fail for unknown side' do
      expect {
        Keepr::Posting.new(side: 'foo')
      }.to raise_error(ArgumentError)
    end
  end

  describe 'scopes' do
    let!(:debit_posting) { Keepr::Posting.create!(amount: 10, side: 'debit', keepr_account: account_1000, keepr_journal_id: 42) }
    let!(:credit_posting) { Keepr::Posting.create!(amount: 10, side: 'credit', keepr_account: account_1000, keepr_journal_id: 42) }

    it 'should filter' do
      expect(account_1000.keepr_postings.debits).to eq([debit_posting])
      expect(account_1000.keepr_postings.credits).to eq([credit_posting])
    end
  end

  describe 'cost_center handling' do
    let!(:cost_center) { FactoryBot.create(:cost_center) }
    let!(:account_8400) { FactoryBot.create(:account, number: 8400, kind: :revenue) }

    it "should allow cost_center" do
      posting = Keepr::Posting.new keepr_account: account_8400, amount: 100, keepr_cost_center: cost_center
      expect(posting).to be_valid
    end

    it "should not allow cost_center" do
      posting = Keepr::Posting.new keepr_account: account_1000, amount: 100, keepr_cost_center: cost_center
      expect(posting).to_not be_valid
    end
  end
end
