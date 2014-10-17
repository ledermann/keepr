require 'spec_helper'

describe Keepr::ActiveRecordExtension do
  let!(:account_1000) { FactoryGirl.create(:account, :number => 1000, :kind => :asset) }
  let!(:account_1200) { FactoryGirl.create(:account, :number => 1200, :kind => :asset) }

  describe 'ledger with associated account' do
    subject do
      ledger = Ledger.create! :bank_name => 'Sparkasse'
      account_1200.update_attributes! :accountable => ledger
      ledger
    end

    it { expect(subject.keepr_account).to be_present }
  end

  describe 'Document with associated journal' do
    subject do
      document = Document.create! :number => 'RE-2013-10-12345'
      Keepr::Journal.create! :accountable => document,
                             :keepr_postings_attributes => [
                               { :keepr_account => account_1000, :amount => 100.99, :side => 'debit'  },
                               { :keepr_account => account_1200, :amount => 100.99, :side => 'credit' }
                             ]
      document
    end

    it 'has 1 keepr_journal' do
      expect(subject.keepr_journals.size).to eq(1)
    end
    it { is_expected.to be_keepr_booked }
  end

  describe 'scopes' do
    let!(:unbooked_document) { Document.create! :number => 'Unbooked' }
    let!(:booked_document) {
      document = Document.create! :number => 'Booked'
      Keepr::Journal.create! :accountable => document,
                             :keepr_postings_attributes => [
                               { :keepr_account => account_1000, :amount => 100.99, :side => 'debit'  },
                               { :keepr_account => account_1200, :amount => 100.99, :side => 'credit' }
                             ]
      document
    }

    describe :keepr_booked do
      subject { Document.keepr_booked }

      it { is_expected.to include(booked_document) }
      it { is_expected.not_to include(unbooked_document) }
    end

    describe :keepr_unbooked do
      subject { Document.keepr_unbooked }

      it { is_expected.to include(unbooked_document) }
      it { is_expected.not_to include(booked_document) }
    end
  end
end
