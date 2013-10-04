require 'spec_helper'

describe Keepr::Item do
  describe 'credit/debit' do
    it 'should be credit for positive amount' do
      Keepr::Item.new(:amount => 10).should be_credit
    end

    it 'should be debit for negative amount' do
      Keepr::Item.new(:amount => -10).should be_debit
    end
  end
end
