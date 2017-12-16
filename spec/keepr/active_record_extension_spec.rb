require 'spec_helper'

describe Keepr::ActiveRecordExtension do
  let(:account_1000) { FactoryBot.create(:account, number: 1000, kind: :asset) }
  let(:account_1200) { FactoryBot.create(:account, number: 1200, kind: :asset) }

  describe 'ledger with associated account' do
    let(:ledger) { Ledger.create! bank_name: 'Sparkasse' }
    let!(:account) { ledger.create_keepr_account! number: '1250', kind: :asset, name: 'Girokonto' }

    it 'has keepr_account' do
      expect(ledger.keepr_account).to eq(account)
    end

    it 'has keepr_postings' do
      journal = Keepr::Journal.create! keepr_postings_attributes: [
                               { keepr_account: account,      amount: 30, side: 'debit'  },
                               { keepr_account: account_1200, amount: 30, side: 'credit' }
                             ]
      other_journal = Keepr::Journal.create! keepr_postings_attributes: [
                               { keepr_account: account_1000, amount: 20, side: 'debit'  },
                               { keepr_account: account_1200, amount: 20, side: 'credit' }
                             ]

      expect(ledger.keepr_postings.count).to eq(1)
      expect(ledger.keepr_postings.first.amount).to eq(30)
    end
  end

  describe 'contact with multiple associated accounts' do
    let(:contact) { Contact.create! name: 'John Doe' }
    let(:account1) { contact.keepr_accounts.create! number: '70001', kind: :debtor, name: "Doe's main account" }
    let(:account2) { contact.keepr_accounts.create! number: '70002', kind: :debtor, name: "Doe's second account" }

    it 'has multiple keepr_accounts' do
      expect(contact.keepr_accounts).to eq([account1, account2])
    end

    it 'has keepr_postings' do
      journal = Keepr::Journal.create! keepr_postings_attributes: [
                               { keepr_account: account1,     amount: 30, side: 'debit'  },
                               { keepr_account: account_1200, amount: 30, side: 'credit' }
                             ]
      other_journal = Keepr::Journal.create! keepr_postings_attributes: [
                               { keepr_account: account_1000, amount: 20, side: 'debit'  },
                               { keepr_account: account_1200, amount: 20, side: 'credit' }
                             ]

      expect(contact.keepr_postings.count).to eq(1)
      expect(contact.keepr_postings.first.amount).to eq(30)
    end
  end

  describe 'Document with associated journal' do
    subject do
      document = Document.create! number: 'RE-2013-10-12345'
      Keepr::Journal.create! accountable: document,
                             keepr_postings_attributes: [
                               { keepr_account: account_1000, amount: 100.99, side: 'debit'  },
                               { keepr_account: account_1200, amount: 100.99, side: 'credit' }
                             ]
      document
    end

    it 'has 1 keepr_journal' do
      expect(subject.keepr_journals.size).to eq(1)
    end
    it { is_expected.to be_keepr_booked }
  end

  describe 'scopes' do
    let!(:unbooked_document) { Document.create! number: 'Unbooked' }
    let!(:booked_document) {
      document = Document.create! number: 'Booked'
      Keepr::Journal.create! accountable: document,
                             keepr_postings_attributes: [
                               { keepr_account: account_1000, amount: 100.99, side: 'debit'  },
                               { keepr_account: account_1200, amount: 100.99, side: 'credit' }
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
