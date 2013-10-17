require 'spec_helper'

describe Keepr::ActiveRecordExtension do
  describe 'ledger with associated account' do
    subject do
      ledger = Ledger.create! :bank_name => 'Sparkasse'
      skr03(1200).update_attributes! :accountable => ledger
      ledger
    end

    it { subject.keepr_account.should be_present }
  end

  describe 'Contact with associated default account' do
    subject do
      Contact.create! :name => 'United Parcel Service', :default_keepr_account => skr03(4910)
    end

    it { subject.default_keepr_account.should be_present }
  end

  describe 'Document with associated journal' do
    subject do
      document = Document.create! :number => 'RE-2013-10-12345'
      Keepr::Journal.create! :accountable => document,
                             :keepr_postings_attributes => [
                               { :keepr_account => skr03(1000), :amount => 100.99, :side => 'debit'  },
                               { :keepr_account => skr03(1200), :amount => 100.99, :side => 'credit' }
                             ]
      document
    end

    it { should have(1).keepr_journal }
    it { should be_keepr_booked }
  end
end
