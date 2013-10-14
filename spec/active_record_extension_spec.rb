require 'spec_helper'

describe Keepr::ActiveRecordExtension do
  describe 'Contact with associated account' do
    subject do
      contact = Contact.create! :name => 'John Doe'
      Keepr::Account.create! :number => 10001, :name => "John's Account", :kind => 'Asset', :accountable => contact
      contact
    end

    it { should have(1).keepr_account }
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
