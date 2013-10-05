require 'spec_helper'

describe Keepr::Item do
  describe 'credit/debit' do
    it 'should be debit for positive amount' do
      Keepr::Item.new(:amount => 10).should be_debit
    end

    it 'should be credit for negative amount' do
      Keepr::Item.new(:amount => -10).should be_credit
    end
  end
end
