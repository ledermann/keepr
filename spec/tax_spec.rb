require 'spec_helper'

describe Keepr::Tax do
  let!(:tax_account) { Keepr::Account.create! :number => 1776,
                                              :name => 'Umsatzsteuer 19%',
                                              :kind => 'Asset' }

  let!(:tax) { Keepr::Tax.create! :name          => 'USt19',
                                  :description   => 'Umsatzsteuer 19%',
                                  :value         => 19.0,
                                  :keepr_account => tax_account }

  let!(:account) { Keepr::Account.create! :number    => 8400,
                                          :name      => 'Erlöse 19% USt',
                                          :kind      => 'Revenue',
                                          :keepr_tax => tax }

  it 'should be direct linked from account' do
    expect(account.keepr_tax).to eq(tax)
    expect(tax_account.keepr_tax).to eq(nil)
  end

  it "should be reverse found from account" do
    expect(tax_account.keepr_taxes).to eq([tax])
    expect(account.keepr_taxes).to eq([])
  end

  it "should avoid circular reference" do
    tax.keepr_account = account
    expect(tax).to be_invalid
  end
end
