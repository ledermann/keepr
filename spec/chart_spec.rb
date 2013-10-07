require 'spec_helper'

describe Keepr::Chart do
  describe :initialize do
    it "should fail with invalid filename" do
      lambda {
        Keepr::Chart.new('foo')
      }.should raise_error(ArgumentError)
    end

    it "should success with valid filename" do
      lambda {
        Keepr::Chart.new('skr03')
      }.should_not raise_error
    end
  end

  describe :load! do
    it "should not insert duplicates" do
      lambda {
        Keepr::Chart.new('skr03').load!
      }.should_not change(Keepr::Account, :count)
    end
  end
end
