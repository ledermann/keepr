require 'spec_helper'

describe Keepr::Account do
  describe :number_as_string do
    it "should return number with leading zeros for low values" do
      account = Keepr::Account.new(:number => 999)
      expect(account.number_as_string).to eq('0999')
    end

    it "should return number unchanged for high values" do
      account = Keepr::Account.new(:number => 70000)
      expect(account.number_as_string).to eq('70000')
    end
  end

  describe :to_s do
    it "should format" do
      account = Keepr::Account.new(:number => 27, :name => 'Software')
      expect(account.to_s).to eq('0027 (Software)')
    end
  end
end

describe Keepr::Account do
  let!(:account_1000) { FactoryGirl.create(:account, :number => 1000) }
  let!(:account_1200) { FactoryGirl.create(:account, :number => 1200) }

  before :each do
    Keepr::Journal.create! :date => Date.yesterday,
                           :keepr_postings_attributes => [
                             { :keepr_account => account_1000, :amount => 20, :side => 'debit' },
                             { :keepr_account => account_1200, :amount => 20, :side => 'credit' }
                            ]

    Keepr::Journal.create! :date => Date.yesterday,
                           :keepr_postings_attributes => [
                             { :keepr_account => account_1000, :amount =>  10, :side => 'credit' },
                             { :keepr_account => account_1200, :amount =>  10, :side => 'debit' },
                            ]

    Keepr::Journal.create! :date => Date.today,
                           :keepr_postings_attributes => [
                             { :keepr_account => account_1000, :amount => 200, :side => 'debit' },
                             { :keepr_account => account_1200, :amount => 200, :side => 'credit' }
                            ]

    Keepr::Journal.create! :date => Date.today,
                           :keepr_postings_attributes => [
                             { :keepr_account => account_1000, :amount => 100, :side => 'credit' },
                             { :keepr_account => account_1200, :amount => 100, :side => 'debit' },
                            ]
  end

  describe "with group" do
    let!(:result_group) { FactoryGirl.create(:group, :is_result => true) }
    let!(:normal_group) { FactoryGirl.create(:group, :is_result => false) }

    it "should not be assigned to result group" do
      account = FactoryGirl.build(:account, :number => 123, :keepr_group => result_group)
      expect(account).to_not be_valid
      expect(account.errors[:keepr_group_id]).to be_present
    end

    it "should be assigned to normal group" do
      account = FactoryGirl.build(:account, :number => 123, :keepr_group => normal_group)
      expect(account).to be_valid
      expect(account.errors[:keepr_group_id]).to be_blank
    end
  end

  describe :balance do
    it 'should calc total' do
      expect(account_1000.balance).to eq(110)
      expect(account_1200.balance).to eq(-110)
    end

    it 'should calc total for a given date (including)' do
      expect(account_1000.balance(Date.today)).to eq(110)
      expect(account_1200.balance(Date.today)).to eq(-110)
    end

    it 'should calc total for a given date (excluding)' do
      expect(account_1000.balance(Date.yesterday)).to eq(10)
      expect(account_1200.balance(Date.yesterday)).to eq(-10)
    end

    it 'should calc total for Range' do
      expect(account_1000.balance(Date.yesterday...Date.today)).to eq(110)
      expect(account_1200.balance(Date.yesterday...Date.today)).to eq(-110)

      expect(account_1000.balance(Date.today...Date.tomorrow)).to eq(100)
      expect(account_1200.balance(Date.today...Date.tomorrow)).to eq(-100)
    end

    it 'should fail for other param' do
      expect { account_1000.balance(0) }.to raise_error(ArgumentError)
    end
  end

  describe :with_balance do
    it 'should work without param' do
      account1, account2 = Keepr::Account.with_balance.having('preloaded_sum_amount <> 0')

      expect(account1.number).to eq(1000)
      expect(account1.balance).to eq(110)
      expect(account2.number).to eq(1200)
      expect(account2.balance).to eq(-110)
    end

    it 'should work with Date' do
      account1, account2 = Keepr::Account.with_balance(Date.yesterday).having('preloaded_sum_amount <> 0')

      expect(account1.number).to eq(1000)
      expect(account1.balance).to eq(10)
      expect(account2.number).to eq(1200)
      expect(account2.balance).to eq(-10)
    end

    it 'should work with Range' do
      account1, account2 = Keepr::Account.with_balance(Date.today..Date.tomorrow).having('preloaded_sum_amount <> 0')

      expect(account1.number).to eq(1000)
      expect(account1.balance).to eq(100)
      expect(account2.number).to eq(1200)
      expect(account2.balance).to eq(-100)
    end

    it 'should raise for other param' do
      expect { Keepr::Account.with_balance(Time.current) }.to raise_error(ArgumentError)
      expect { Keepr::Account.with_balance(0)            }.to raise_error(ArgumentError)
      expect { Keepr::Account.with_balance(:foo)         }.to raise_error(ArgumentError)
    end
  end
end

describe Keepr::Account, 'with subaccounts' do
  let!(:account_1400) { FactoryGirl.create(:account, :number => 1400) }
  let!(:account_10000) { FactoryGirl.create(:account, :number => 10000, :parent => account_1400) }
  let!(:account_8400) { FactoryGirl.create(:account, :number => 8400) }

  before :each do
    Keepr::Journal.create! :date => Date.yesterday,
                           :keepr_postings_attributes => [
                             { :keepr_account => account_10000, :amount => 20, :side => 'debit' },
                             { :keepr_account => account_8400, :amount => 20, :side => 'credit' }
                            ]
  end

  describe :keepr_postings do
    it 'should include postings from descendant accounts' do
      expect(account_1400.keepr_postings.size).to eq(1)
      expect(account_10000.keepr_postings.size).to eq(1)
    end
  end

  describe :balance do
    it 'should include postings from descendant accounts' do
      expect(account_1400.reload.balance).to eq(20)
      expect(account_10000.reload.balance).to eq(20)
    end

    it 'should include postings from descendant accounts with date given' do
      expect(account_1400.balance(Date.today)).to eq(20)
      expect(account_10000.balance(Date.today)).to eq(20)
    end
  end

  describe :with_balance do
    it 'should calc balance' do
      expect(Keepr::Account.with_balance.
                     select { |a| (a.preloaded_sum_amount || 0) != 0 }.
                     map { |a| [a.number, a.preloaded_sum_amount] }).
                     to eq([[8400, -20], [10000, 20]])
    end
  end

  describe :merged_with_balance do
    it 'should calc merged balance' do
      expect(Keepr::Account.merged_with_balance.
                     select { |a| (a.preloaded_sum_amount || 0) != 0 }.
                     map { |a| [a.number, a.preloaded_sum_amount] }).
                     to eq([[1400, 20], [8400, -20]])
    end
  end
end

describe Keepr::Account, 'with tax' do
  let!(:tax_account) { Keepr::Account.create! :number => 1776,
                                              :name => 'Umsatzsteuer 19%',
                                              :kind => 'Asset' }

  let!(:tax) { Keepr::Tax.create! :name          => 'USt19',
                                  :description   => 'Umsatzsteuer 19%',
                                  :value         => 19.0,
                                  :keepr_account => tax_account }

  it "should link to tax" do
    account = Keepr::Account.new :number    => 8400,
                                 :name      => 'Erlöse 19% USt',
                                 :kind      => 'Revenue',
                                 :keepr_tax => tax
    expect(tax_account).to be_valid
  end

  it "should avoid circular reference" do
    tax_account.keepr_tax_id = tax.id
    expect(tax_account).to be_invalid
  end
end
