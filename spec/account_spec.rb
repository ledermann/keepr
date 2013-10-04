require 'spec_helper'

describe Keepr::Account do
  include AccountSystem

  describe :balance do
    context 'without transactions' do
      it 'should be zero' do
        skr03(1000).balance.should be_zero
        skr03(1200).balance.should be_zero
      end
    end

    context 'with transactions' do
      before :each do
        Keepr::Transaction.create! :subject          => 'Get cash from bank account',
                                   :items_attributes => [
                                     { :account => skr03(1000), :amount =>  200 },
                                     { :account => skr03(1200), :amount => -200 }
                                    ]

        Keepr::Transaction.create! :subject          => 'Bring cash to bank account',
                                   :items_attributes => [
                                     { :account => skr03(1000), :amount => -100 },
                                     { :account => skr03(1200), :amount =>  100 },
                                    ]
      end

      it 'should calc total' do
        skr03(1000).balance.should ==  100
        skr03(1200).balance.should == -100
      end
    end
  end
end
