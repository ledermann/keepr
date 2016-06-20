require 'spec_helper'

describe Keepr::GroupsCreator do
  context 'balance groups' do
    before :each do
      Keepr::GroupsCreator.new(:balance).run
    end

    it "should create groups" do
      expect(Keepr::Group.count).to eq(64)
      expect(Keepr::Group.asset.count).to eq(36)
      expect(Keepr::Group.liability.count).to eq(28)

      compare_with_source(Keepr::Group.asset, 'asset.txt')
      compare_with_source(Keepr::Group.liability, 'liability.txt')
    end

    it "should create result group" do
      expect(Keepr::Group.result).to be_a(Keepr::Group)
    end
  end

  context 'profit & loss groups' do
    before :each do
      Keepr::GroupsCreator.new(:profit_and_loss).run
    end

    it "should create profit & loss groups" do
      expect(Keepr::Group.count).to eq(31)
      expect(Keepr::Group.profit_and_loss.count).to eq(31)

      compare_with_source(Keepr::Group.profit_and_loss, 'profit_and_loss.txt')
    end
  end

private
  def compare_with_source(scope, filename)
    full_filename = File.join(File.dirname(__FILE__), "../../lib/keepr/groups_creator/#{filename}")
    source = File.read(full_filename)

    lines = scope.find_each.map { |g| "#{' ' * g.depth * 2}#{g.number} #{g.name}\n" }.join

    expect(lines).to eq(source)
  end
end
