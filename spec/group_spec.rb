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
end
