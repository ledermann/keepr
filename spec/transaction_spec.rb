require 'spec_helper'

describe Keepr::Transaction do
  include AccountSystem

  let :simple_transaction do
    Keepr::Transaction.create :items_attributes => [
                                { :account => skr03(1000), :amount =>  100 },
                                { :account => skr03(1200), :amount => -100 }
                              ]
  end

  let :complex_transaction do
    Keepr::Transaction.create :items_attributes => [
                                { :account => skr03(4920), :amount =>   8.40 },
                                { :account => skr03(1576), :amount =>   1.60 },
                                { :account => skr03(1600), :amount => -10.00 }
                               ]
  end

  let :transaction_with_only_one_item do
    Keepr::Transaction.create :items_attributes => [
                                { :account => skr03(4920), :amount => 8.40 }
                              ]
  end

  let :unbalanced_transaction do
    Keepr::Transaction.create :items_attributes => [
                                { :account => skr03(1000), :amount => 10 },
                                { :account => skr03(1200), :amount => 10 }
                              ]
  end

  describe :initialization do
    context 'with date missing' do
      it 'should set date to today' do
        Keepr::Transaction.new.date.should == Date.today
      end
    end

    context 'with date given' do
      it 'should not modify the date' do
        old_date = Date.new(2013,10,1)
        Keepr::Transaction.new(:date => old_date).date.should == old_date
      end
    end
  end

  describe :validation do
    it 'should success for valid transactions' do
      simple_transaction.should be_valid
      complex_transaction.should be_valid
    end

    it 'should fail for invalid transactions' do
      transaction_with_only_one_item.should_not be_valid
      unbalanced_transaction.should_not be_valid
    end
  end

  describe :items do
    it 'should return items' do
      simple_transaction.should have(2).items
      complex_transaction.should have(3).items
    end
  end

  describe :credit_items do
    it 'should return items with positive amount' do
      simple_transaction.should have(1).credit_items
      complex_transaction.should have(1).credit_items
    end
  end

  describe :debit_items do
    it 'should return items with negative amount' do
      simple_transaction.should have(1).debit_items
      complex_transaction.should have(2).debit_items
    end
  end

  describe :amount do
    it 'should return absolute amount' do
      simple_transaction.amount.should == 100
      complex_transaction.amount.should == 10
    end
  end
end
