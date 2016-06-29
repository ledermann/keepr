require 'spec_helper'

describe Keepr::AccountExport do
  let!(:account_1000)  { FactoryGirl.create :account, :number => 1000, :name => 'Kasse' }
  let!(:account_1200)  { FactoryGirl.create :account, :number => 1200, :name => 'Girokonto' }
  let!(:account_1576)  { FactoryGirl.create :account, :number => 1576, :name => 'Abziehbare Vorsteuer 19 %' }
  let!(:account_1776)  { FactoryGirl.create :account, :number => 1776, :name => 'Umsatzsteuer 19 %' }

  let(:scope) { Keepr::Account.all }

  let(:export) {
    Keepr::AccountExport.new(scope,
      'Berater'     => 1234567,
      'Mandant'     => 78901,
      'WJ-Beginn'   => Date.new(2016,1,1),
      'Bezeichnung' => 'Keepr-Konten'
    )
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
      expect(subject.lines[0]).to include('Keepr-Konten;')
    end

    it "should include row data" do
      expect(account_lines.count).to eq(4)

      expect(account_lines[0]).to include('1000;')
      expect(account_lines[0]).to include('Kasse;')

      expect(account_lines[1]).to include('1200;')
      expect(account_lines[1]).to include('Girokonto;')

      expect(account_lines[2]).to include('1576;')
      expect(account_lines[2]).to include('Abziehbare Vorsteuer 19 %;')

      expect(account_lines[3]).to include('1776;')
      expect(account_lines[3]).to include('Umsatzsteuer 19 %;')
    end
  end

  describe :to_file do
    it "should create CSV file" do
      Dir.mktmpdir do |dir|
        filename = "#{dir}/EXTF_Kontenbeschriftungen.csv"
        export.to_file(filename)

        expect(File).to exist(filename)
      end
    end
  end
end
