require 'spec_helper'

describe Keepr::Journal do
  let!(:account_1000) { FactoryGirl.create(:account, :number => 1000, :kind => 'Asset') }
  let!(:account_1200) { FactoryGirl.create(:account, :number => 1200, :kind => 'Asset') }
  let!(:account_1210) { FactoryGirl.create(:account, :number => 1210, :kind => 'Asset') }
  let!(:account_4910) { FactoryGirl.create(:account, :number => 4910, :kind => 'Expense') }
  let!(:account_4920) { FactoryGirl.create(:account, :number => 4920, :kind => 'Expense') }
  let!(:account_1576) { FactoryGirl.create(:account, :number => 1576, :kind => 'Asset') }
  let!(:account_1600) { FactoryGirl.create(:account, :number => 1600, :kind => 'Liability') }

  let :simple_journal do
    Keepr::Journal.create :keepr_postings_attributes => [
                                { :keepr_account => account_1000, :amount => 100.99, :side => 'debit' },
                                { :keepr_account => account_1200, :amount => 100.99, :side => 'credit' }
                              ]
  end

  let :complex_journal do
    Keepr::Journal.create :keepr_postings_attributes => [
                                { :keepr_account => account_4920, :amount =>  8.40, :side => 'debit' },
                                { :keepr_account => account_1576, :amount =>  1.60, :side => 'debit' },
                                { :keepr_account => account_1600, :amount => 10.00, :side => 'credit' }
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

    it 'should accept journal with postings marked for destruction' do
      complex_journal.keepr_postings.first.mark_for_destruction
      complex_journal.keepr_postings.build :keepr_account => account_4910, :amount => 8.4, :side => 'debit'

      complex_journal.should be_valid
    end

    it 'should fail for journal with only one posting' do
      journal = Keepr::Journal.create :keepr_postings_attributes => [
                                  { :keepr_account => account_4920, :amount => 8.40, :side => 'debit' }
                                ]
      journal.should_not be_valid
    end

    it 'should fail for booking the same account twice' do
      journal = Keepr::Journal.create :keepr_postings_attributes => [
                                  { :keepr_account => account_1000, :amount => 10, :side => 'debit' },
                                  { :keepr_account => account_1000, :amount => 10, :side => 'credit' }
                                ]
      journal.should_not be_valid
    end

    it 'should fail for unbalanced journal' do
      journal = Keepr::Journal.create :keepr_postings_attributes => [
                                  { :keepr_account => account_1000, :amount => 10, :side => 'debit' },
                                  { :keepr_account => account_1200, :amount => 10, :side => 'debit' }
                                ]
      journal.should_not be_valid
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

    it 'should ignore postings marked for destruction' do
      complex_journal.keepr_postings.last.mark_for_destruction
      complex_journal.amount.should == 0
    end
  end

  describe :create do
    let(:debit_account) { account_1000 }
    let(:credit_account) { account_1200 }

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

  describe :destroy do
    let(:debit_account) { account_1000 }
    let(:credit_account) { account_1200 }

    before :each do
      @journal = Keepr::Journal.create! :keepr_postings_attributes => [
                                          { :keepr_account => debit_account,  :amount => 100.99, :side => 'debit' },
                                          { :keepr_account => credit_account, :amount => 100.99, :side => 'credit' }
                                        ]
    end

    subject do
      lambda { @journal.destroy }
    end

    describe 'debit_account' do
      it { should change(debit_account, :keepr_postings_count).by(-1) }
      it { should change(debit_account, :keepr_postings_sum_amount).by(-100.99) }
    end

    describe 'credit_account' do
      it { should change(credit_account, :keepr_postings_count).by(-1) }
      it { should change(credit_account, :keepr_postings_sum_amount).by(100.99) }
    end
  end

  describe :update do
    let(:debit_account) { account_1000 }
    let(:credit_account) { account_1200 }
    let(:other_account) { account_1210 }

    before :each do
      @journal = Keepr::Journal.create! :keepr_postings_attributes => [
                                          { :keepr_account => debit_account,  :amount => 100.99, :side => 'debit' },
                                          { :keepr_account => credit_account, :amount => 100.99, :side => 'credit' }
                                        ]
    end

    subject do
      lambda {
        @journal.credit_postings.first.keepr_account = other_account
        @journal.save!
        credit_account.reload
      }
    end

    describe 'credit_account' do
      it { should change(credit_account, :keepr_postings_count).by(-1) }
      it { should change(credit_account, :keepr_postings_sum_amount).by(100.99) }
    end

    describe 'other_account' do
      it { should change(other_account, :keepr_postings_count).by(1) }
      it { should change(other_account, :keepr_postings_sum_amount).by(-100.99) }
    end
  end
end
