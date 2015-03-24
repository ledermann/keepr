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

    it 'has keepr_account' do
      expect(subject.keepr_account).to eq(account_1200)
    end
  end

  describe 'contact with multiple associated accounts' do
    let(:contact) { Contact.create! :name => 'John Doe' }
    let(:account1) { contact.keepr_accounts.create! :number => '70001', :kind => :debtor, :name => "Doe's main account" }
    let(:account2) { contact.keepr_accounts.create! :number => '70002', :kind => :debtor, :name => "Doe's second account" }

    it 'has multiple keepr_accounts' do
      expect(contact.keepr_accounts).to eq([account1, account2])
    end
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
