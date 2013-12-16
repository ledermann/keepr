require 'spec_helper'

describe Keepr::ActiveRecordExtension do
  let!(:account_1000) { FactoryGirl.create(:account, :number => 1000, :kind => 'Asset') }
  let!(:account_1200) { FactoryGirl.create(:account, :number => 1200, :kind => 'Asset') }

  describe 'ledger with associated account' do
    subject do
      ledger = Ledger.create! :bank_name => 'Sparkasse'
      account_1200.update_attributes! :accountable => ledger
      ledger
    end

    it { subject.keepr_account.should be_present }
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

    it { should have(1).keepr_journal }
    it { should be_keepr_booked }
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

      it { should include(booked_document) }
      it { should_not include(unbooked_document) }
    end

    describe :keepr_unbooked do
      subject { Document.keepr_unbooked }

      it { should include(unbooked_document) }
      it { should_not include(booked_document) }
    end
  end
end
