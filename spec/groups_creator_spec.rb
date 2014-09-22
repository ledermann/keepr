require 'spec_helper'

describe Keepr::GroupsCreator do
  it "should create balance groups" do
    Keepr::GroupsCreator.new('Balance').run

    expect(Keepr::Group.count).to eq(64)
    expect(Keepr::Group.asset.count).to eq(36)
    expect(Keepr::Group.liability.count).to eq(28)

    compare_with_source(Keepr::Group.asset, 'asset.txt')
    compare_with_source(Keepr::Group.liability, 'liability.txt')
  end

  it "should create lost & profit groups" do
    Keepr::GroupsCreator.new('Lost & Profit').run

    expect(Keepr::Group.count).to eq(31)
    expect(Keepr::Group.lost_and_profit.count).to eq(31)

    compare_with_source(Keepr::Group.lost_and_profit, 'lost_and_profit.txt')
  end

private
  def compare_with_source(scope, filename)
    full_filename = File.join(__dir__, "../lib/keepr/groups_creator/#{filename}")
    source = File.read(full_filename)

    lines = scope.find_each.map { |g| "#{' ' * g.depth * 2}#{g.name}\n" }.join

    expect(lines).to eq(source)
  end
end
