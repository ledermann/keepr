require 'spec_helper'

describe Keepr::ContactExport do
  let!(:account_1000)  { FactoryGirl.create :account, :kind => :asset,     :number => 1000,  :name => 'Kasse'      }
  let!(:account_10000) { FactoryGirl.create :account, :kind => :creditor,  :number => 10000, :name => 'Meyer GmbH' }
  let!(:account_70000) { FactoryGirl.create :account, :kind => :debtor,    :number => 70000, :name => 'Schulze AG' }

  let(:scope) { Keepr::Account.all }

  let(:export) {
    Keepr::ContactExport.new(scope,
      'Berater'     => 1234567,
      'Mandant'     => 78901,
      'WJ-Beginn'   => Date.new(2016,1,1),
      'Bezeichnung' => 'Keepr-Kontakte'
    ) do |account|
      { 'Kurzbezeichnung' => account.name }
    end
  }

  describe :to_s do
    subject { export.to_s }

    def account_lines
      subject.lines[2..-1]
    end

    it "should return CSV lines" do
      subject.lines.each { |line| expect(line).to include(';') }
    end

    it "should include header data" do
      expect(subject.lines[0]).to include('1234567;')
      expect(subject.lines[0]).to include('78901;')
      expect(subject.lines[0]).to include('"Keepr-Kontakte";')
    end

    it "should include debtor/creditor accounts only" do
      expect(account_lines.count).to eq(2)

      expect(account_lines[0]).to include('10000;')
      expect(account_lines[1]).to include('70000;')
    end

    it "should include data from block" do
      expect(account_lines[0]).to include('"Meyer GmbH";')
      expect(account_lines[1]).to include('"Schulze AG";')
    end
  end

  describe :to_file do
    it "should create CSV file" do
      Dir.mktmpdir do |dir|
        filename = "#{dir}/EXTF_Stammdaten.csv"
        export.to_file(filename)

        expect(File).to exist(filename)
      end
    end
  end
end
