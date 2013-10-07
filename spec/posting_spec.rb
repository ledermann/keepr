require 'spec_helper'

describe Keepr::Posting do
  describe 'credit/debit' do
    it 'should be debit for positive amount' do
      Keepr::Posting.new(:amount => 10).should be_debit
    end

    it 'should be credit for negative amount' do
      Keepr::Posting.new(:amount => -10).should be_credit
    end
  end
end
