require 'spec_helper'

describe Keepr::Journal do
  let :simple_journal do
    Keepr::Journal.create :keepr_postings_attributes => [
                                { :keepr_account => skr03(1000), :amount => 100.99, :side => 'debit' },
                                { :keepr_account => skr03(1200), :amount => 100.99, :side => 'credit' }
                              ]
  end

  let :complex_journal do
    Keepr::Journal.create :keepr_postings_attributes => [
                                { :keepr_account => skr03(4920), :amount =>  8.40, :side => 'debit' },
                                { :keepr_account => skr03(1576), :amount =>  1.60, :side => 'debit' },
                                { :keepr_account => skr03(1600), :amount => 10.00, :side => 'credit' }
                               ]
  end

  let :journal_with_only_one_posting do
    Keepr::Journal.create :keepr_postings_attributes => [
                                { :keepr_account => skr03(4920), :amount => 8.40, :side => 'debit' }
                              ]
  end

  let :unbalanced_journal do
    Keepr::Journal.create :keepr_postings_attributes => [
                                { :keepr_account => skr03(1000), :amount => 10, :side => 'debit' },
                                { :keepr_account => skr03(1200), :amount => 10, :side => 'debit' }
                              ]
  end

  describe :initialization do
    context 'with date missing' do
      it 'should set date to today' do
        Keepr::Journal.new.date.should == Date.today
      end
    end

    context 'with date given' do
      it 'should not modify the date' do
        old_date = Date.new(2013,10,1)
        Keepr::Journal.new(:date => old_date).date.should == old_date
      end
    end
  end

  describe :validation do
    it 'should success for valid journals' do
      simple_journal.should be_valid
      complex_journal.should be_valid
    end

    it 'should fail for invalid journals' do
      journal_with_only_one_posting.should_not be_valid
      unbalanced_journal.should_not be_valid
    end
  end

  describe :postings do
    it 'should return postings' do
      simple_journal.should have(2).keepr_postings
      complex_journal.should have(3).keepr_postings
    end
  end

  describe :credit_postings do
    it 'should return postings with positive amount' do
      simple_journal.should have(1).credit_postings
      complex_journal.should have(1).credit_postings
    end
  end

  describe :debit_postings do
    it 'should return postings with negative amount' do
      simple_journal.should have(1).debit_postings
      complex_journal.should have(2).debit_postings
    end
  end

  describe :amount do
    it 'should return absolute amount' do
      simple_journal.amount.should == 100.99
      complex_journal.amount.should == 10
    end
  end

  describe :after_save do
    let(:debit_account) { skr03(1000) }
    let(:credit_account) { skr03(1200) }

    subject do
      lambda { Keepr::Journal.create! :keepr_postings_attributes => [
                                        { :keepr_account => debit_account,  :amount => 100.99, :side => 'debit' },
                                        { :keepr_account => credit_account, :amount => 100.99, :side => 'credit' }
                                      ] }
    end

    describe 'debit account' do
      it { should change(debit_account, :keepr_postings_count).by(1) }
      it { should change(debit_account, :keepr_postings_sum_amount).by(100.99) }
    end

    describe 'credit account' do
      it { should change(credit_account, :keepr_postings_count).by(1) }
      it { should change(credit_account, :keepr_postings_sum_amount).by(-100.99) }
    end
  end
end
