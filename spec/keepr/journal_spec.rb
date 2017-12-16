require 'spec_helper'

describe Keepr::Journal do
  let!(:account_1000) { FactoryBot.create(:account, number: 1000, kind: :asset) }
  let!(:account_1200) { FactoryBot.create(:account, number: 1200, kind: :asset) }
  let!(:account_1210) { FactoryBot.create(:account, number: 1210, kind: :asset) }
  let!(:account_4910) { FactoryBot.create(:account, number: 4910, kind: :expense) }
  let!(:account_4920) { FactoryBot.create(:account, number: 4920, kind: :expense) }
  let!(:account_1576) { FactoryBot.create(:account, number: 1576, kind: :asset) }
  let!(:account_1600) { FactoryBot.create(:account, number: 1600, kind: :liability) }

  let :simple_journal do
    Keepr::Journal.create keepr_postings_attributes: [
                                { keepr_account: account_1000, amount: 100.99, side: 'debit' },
                                { keepr_account: account_1200, amount: 100.99, side: 'credit' }
                              ]
  end

  let :complex_journal do
    Keepr::Journal.create keepr_postings_attributes: [
                                { keepr_account: account_4920, amount:  8.40, side: 'debit' },
                                { keepr_account: account_1576, amount:  1.60, side: 'debit' },
                                { keepr_account: account_1600, amount: 10.00, side: 'credit' }
                               ]
  end

  describe :initialization do
    context 'with date missing' do
      it 'should set date to today' do
        expect(Keepr::Journal.new.date).to eq(Date.today)
      end
    end

    context 'with date given' do
      it 'should not modify the date' do
        old_date = Date.new(2013,10,1)
        expect(Keepr::Journal.new(date: old_date).date).to eq(old_date)
      end
    end
  end

  describe :validation do
    it 'should success for valid journals' do
      expect(simple_journal).to be_valid
      expect(complex_journal).to be_valid
    end

    it 'should accept journal with postings marked for destruction' do
      complex_journal.keepr_postings.first.mark_for_destruction
      complex_journal.keepr_postings.build keepr_account: account_4910, amount: 8.4, side: 'debit'

      expect(complex_journal).to be_valid
    end

    it 'should fail for journal with only one posting' do
      journal = Keepr::Journal.create keepr_postings_attributes: [
                                  { keepr_account: account_4920, amount: 8.40, side: 'debit' }
                                ]
      expect(journal).not_to be_valid
      expect(journal.errors.added? :base, :account_missing).to eq(true)
    end

    it 'should fail for booking the same account twice' do
      journal = Keepr::Journal.create keepr_postings_attributes: [
                                  { keepr_account: account_1000, amount: 10, side: 'debit' },
                                  { keepr_account: account_1000, amount: 10, side: 'credit' }
                                ]
      expect(journal).not_to be_valid
      expect(journal.errors.added? :base, :account_missing).to eq(true)
    end

    it 'should fail for unbalanced journal' do
      journal = Keepr::Journal.create keepr_postings_attributes: [
                                  { keepr_account: account_1000, amount: 10, side: 'debit' },
                                  { keepr_account: account_1200, amount: 10, side: 'debit' }
                                ]
      expect(journal).not_to be_valid
      expect(journal.errors.added? :base, :amount_mismatch).to eq(true)
    end

    it 'should fail for nil amount' do
      journal = Keepr::Journal.create keepr_postings_attributes: [
                                  { keepr_account: account_1000, amount: 10,  side: 'debit' },
                                  { keepr_account: account_1200, amount: nil, side: 'credit' }
                                ]
      expect(journal).not_to be_valid
      expect(journal.errors.added? :base, :amount_mismatch).to eq(true)
    end
  end

  describe :permanent do
    before :each do
      simple_journal.update_attributes! permanent: true
    end

    it "should not allow update" do
      expect(simple_journal.update_attributes subject: 'foo').to eq(false)
      expect(simple_journal.errors.added? :base, :changes_not_allowed).to eq(true)
    end

    it "should not allow destroy" do
      expect(simple_journal.destroy).to eq(false)
      expect(simple_journal.errors.added? :base, :changes_not_allowed).to eq(true)
    end
  end

  describe :postings do
    it 'should return postings' do
      expect(simple_journal.keepr_postings.size).to eq(2)
      expect(complex_journal.keepr_postings.size).to eq(3)
    end

    it 'should order postings' do
      expect(simple_journal.keepr_postings.map(&:side)).to eq(['debit','credit'])
      expect(complex_journal.keepr_postings.map(&:side)).to eq(['debit','debit','credit'])
    end
  end

  describe :credit_postings do
    it 'should return postings with positive amount' do
      expect(simple_journal.credit_postings.size).to eq(1)
      expect(complex_journal.credit_postings.size).to eq(1)
    end
  end

  describe :debit_postings do
    it 'should return postings with negative amount' do
      expect(simple_journal.debit_postings.size).to eq(1)
      expect(complex_journal.debit_postings.size).to eq(2)
    end
  end

  describe :amount do
    it 'should return absolute amount' do
      expect(simple_journal.amount).to eq(100.99)
      expect(complex_journal.amount).to eq(10)
    end
  end
end
