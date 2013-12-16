require 'spec_helper'

describe Keepr::Posting do
  let!(:account_1000) { FactoryGirl.create(:account, :number => 1000, :kind => 'Asset') }

  describe 'side/amount' do
    it 'should handle empty object' do
      posting = Keepr::Posting.new
      posting.amount.should be_nil
      posting.side.should be_nil
    end

    it 'should set credit amount' do
      posting = Keepr::Posting.new :amount => 10, :side => 'credit'

      posting.should be_credit
      posting.amount.should == 10
    end

    it 'should set debit amount' do
      posting = Keepr::Posting.new :amount => 10, :side => 'debit'

      posting.should be_debit
      posting.amount.should == 10
    end

    it 'should set side and amount in different steps' do
      posting = Keepr::Posting.new

      posting.side = 'credit'
      posting.should be_credit
      posting.amount.should be_nil

      posting.amount = 10
      posting.should be_credit
      posting.amount.should == 10
    end

    it 'should change to credit' do
      posting = Keepr::Posting.new :amount => 10, :side => 'debit'
      posting.side = 'credit'

      posting.should be_credit
      posting.amount.should == 10
    end

    it 'should change to debit' do
      posting = Keepr::Posting.new :amount => 10, :side => 'credit'
      posting.side = 'debit'

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
      posting = Keepr::Posting.create!(:amount => 10, :side => 'debit', :keepr_account => account_1000, :keepr_journal_id => 42)
      posting.reload

      posting.should be_debit
      posting.amount.should == 10
    end

    it 'should recognized saved credit posting' do
      posting = Keepr::Posting.create!(:amount => 10, :side => 'credit', :keepr_account => account_1000, :keepr_journal_id => 42)
      posting.reload

      posting.should be_credit
      posting.amount.should == 10
    end

    it 'should fail for negative amount' do
      lambda {
        Keepr::Posting.new(:amount => -10)
      }.should raise_error(ArgumentError)
    end

    it 'should fail for unknown side' do
      lambda {
        Keepr::Posting.new(:side => 'foo')
      }.should raise_error(ArgumentError)
    end
  end
end
