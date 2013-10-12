require 'spec_helper'

describe Keepr::Posting do
  describe 'kind/amount' do
    it 'should handle empty object' do
      posting = Keepr::Posting.new
      posting.amount.should be_nil
      posting.kind.should be_nil
    end

    it 'should set credit amount' do
      posting = Keepr::Posting.new :amount => 10, :kind => 'credit'

      posting.should be_credit
      posting.amount.should == 10
    end

    it 'should set debit amount' do
      posting = Keepr::Posting.new :amount => 10, :kind => 'debit'

      posting.should be_debit
      posting.amount.should == 10
    end

    it 'should change to credit' do
      posting = Keepr::Posting.new :amount => 10, :kind => 'debit'
      posting.kind = 'credit'

      posting.should be_credit
      posting.amount.should == 10
    end

    it 'should change to debit' do
      posting = Keepr::Posting.new :amount => 10, :kind => 'credit'
      posting.kind = 'debit'

      posting.should be_debit
      posting.amount.should == 10
    end

    it 'should default to debit' do
      posting = Keepr::Posting.new :amount => 10

      posting.should be_debit
      posting.amount.should == 10
    end

    it 'should handle string amount' do
      posting = Keepr::Posting.new :amount => '0.5'

      posting.should be_debit
      posting.amount.should == 0.5
    end

    it 'should recognized saved debit posting' do
      posting = Keepr::Posting.create!(:amount => 10, :kind => 'debit', :keepr_account_id => 42, :keepr_journal_id => 43)
      posting.reload

      posting.should be_debit
      posting.amount.should == 10
    end

    it 'should recognized saved credit posting' do
      posting = Keepr::Posting.create!(:amount => 10, :kind => 'credit', :keepr_account_id => 42, :keepr_journal_id => 43)
      posting.reload

      posting.should be_credit
      posting.amount.should == 10
    end

    it 'should fail for negative amount' do
      lambda {
        Keepr::Posting.new(:amount => -10)
      }.should raise_error(ArgumentError)
    end

    it 'should fail for unknown kind' do
      lambda {
        Keepr::Posting.new(:kind => 'foo')
      }.should raise_error(ArgumentError)
    end
  end
end
