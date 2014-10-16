require 'spec_helper'

describe Keepr::Group do
  describe :get_from_parent do
    it 'should preset parent' do
      root = FactoryGirl.create :group, :target => 'Asset'
      child = root.children.create! :name => 'Bar'

      expect(child.target).to eq('Asset')
    end
  end

  describe :keepr_accounts do
    it 'should not destroy if there are accounts' do
      group = FactoryGirl.create :group
      account = FactoryGirl.create :account, :number => 1000, :keepr_group => group

      expect { group.destroy }.to_not change { Keepr::Group.count }
      expect(group.destroy).to eq(false)
      expect(group.reload).to eq(group)
    end

    it 'should destroy if there are no accounts' do
      group = FactoryGirl.create :group

      expect { group.destroy }.to change { Keepr::Group.count }.by(-1)
    end
  end

  describe :keepr_postings do
    let(:group_1)     { FactoryGirl.create :group }
    let(:group_1_1)   { FactoryGirl.create :group, :parent => group_1 }
    let(:group_1_1_1) { FactoryGirl.create :group, :parent => group_1_1 }
    let(:group_2)     { FactoryGirl.create :group }

    let(:account_1a)  { FactoryGirl.create :account, :number => '0001', :keepr_group => group_1_1_1 }
    let(:account_1b)  { FactoryGirl.create :account, :number => '0011', :keepr_group => group_1_1_1 }
    let(:account_1c)  { FactoryGirl.create :account, :number => '0111', :keepr_group => group_1_1_1 }

    let(:account_2)   { FactoryGirl.create :account, :number => '8400', :keepr_group => group_2 }

    let!(:journal1)   { Keepr::Journal.create! :keepr_postings_attributes => [
                          { :keepr_account => account_1a, :amount => 100.99, :side => 'debit' },
                          { :keepr_account => account_2,  :amount => 100.99, :side => 'credit' }
                        ]
                      }
    let!(:journal2)   { Keepr::Journal.create! :keepr_postings_attributes => [
                          { :keepr_account => account_1b, :amount => 100.99, :side => 'debit' },
                          { :keepr_account => account_2, :amount => 100.99, :side => 'credit' }
                        ]
                      }
    let!(:journal3)   { Keepr::Journal.create! :keepr_postings_attributes => [
                          { :keepr_account => account_1c, :amount => 100.99, :side => 'debit' },
                          { :keepr_account => account_2,  :amount => 100.99, :side => 'credit' }
                        ]
                      }

    it "should return postings of all accounts within the group" do
      postings_1 = [journal1.debit_postings.first, journal2.debit_postings.first, journal3.debit_postings.first]
      expect(group_1.keepr_postings).to eq(postings_1)
      expect(group_1_1.keepr_postings).to eq(postings_1)
      expect(group_1_1_1.keepr_postings).to eq(postings_1)

      postings_2 = [journal1.credit_postings.first, journal2.credit_postings.first, journal3.credit_postings.first]
      expect(group_2.keepr_postings).to eq(postings_2)
    end
  end
end
