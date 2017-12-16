require 'spec_helper'

describe Keepr::CostCenter do
  let(:cost_center) { FactoryBot.create(:cost_center) }
  let(:account)     { FactoryBot.create(:account, number: 8400, kind: :revenue) }

  it 'should have postings' do
    posting = Keepr::Posting.create! amount: 10,
                                     side: 'debit',
                                     keepr_account: account,
                                     keepr_cost_center: cost_center,
                                     keepr_journal_id: 42

    expect(cost_center.keepr_postings).to eq([posting])
  end
end
