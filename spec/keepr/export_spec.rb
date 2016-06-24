require 'spec_helper'

describe Keepr::Export do
  let(:account_1000) { FactoryGirl.create(:account, :number => 1000, :kind => :asset) }
  let(:account_1200) { FactoryGirl.create(:account, :number => 1200, :kind => :asset) }
  let(:account_4920) { FactoryGirl.create(:account, :number => 4920, :kind => :expense) }
  let(:account_1576) { FactoryGirl.create(:account, :number => 1576, :kind => :asset) }
  let(:account_1600) { FactoryGirl.create(:account, :number => 1600, :kind => :liability) }

  let! :journal_with_2_postings do
    Keepr::Journal.create! :number                    => 'BELEG-1',
                           :subject                   => 'Geldautomat',
                           :date                      => Date.new(2016,06,23),
                           :keepr_postings_attributes => [
                             { :keepr_account => account_1000, :amount => 105, :side => 'debit' },
                             { :keepr_account => account_1200, :amount => 105, :side => 'credit' }
                           ]
  end

  let! :journal_with_3_postings do
    Keepr::Journal.create! :number                    => 'BELEG-2',
                           :subject                   => 'Telefonrechnung',
                           :date                      => Date.new(2016,06,24),
                           :keepr_postings_attributes => [
                             { :keepr_account => account_4920, :amount =>  8.40, :side => 'debit' },
                             { :keepr_account => account_1576, :amount =>  1.60, :side => 'debit' },
                             { :keepr_account => account_1600, :amount => 10.00, :side => 'credit' }
                           ]
  end

  let(:scope) { Keepr::Journal.reorder(:number) }

  let(:export) {
    Keepr::Export.new(scope,
      'Berater'     => 1234567,
      'Mandant'     => 78901,
      'Datum vom'   => Date.new(2016,6,1),
      'Datum bis'   => Date.new(2016,6,30),
      'WJ-Beginn'   => Date.new(2016,1,1),
      'Bezeichnung' => 'Keepr-Buchungen'
    )
  }

  describe :to_s do
    subject { export.to_s }

    it "should return CSV lines" do
      expect(subject.lines.count).to eq(5)
      subject.lines.each { |line| expect(line).to include(';') }
    end

    it "should include header data" do
      expect(subject.lines[0]).to include('1234567;')
      expect(subject.lines[0]).to include('78901;')
      expect(subject.lines[0]).to include('20160601;20160630;')
      expect(subject.lines[0]).to include('Keepr-Buchungen;')
    end

    it "should include data from journal_with_2_postings" do
      expect(subject.lines[2]).to include('Geldautomat;')
      expect(subject.lines[2]).to include('1000;')
      expect(subject.lines[2]).to include('1200;')
      expect(subject.lines[2]).to include('105,00;')
      expect(subject.lines[2]).to include(';S;')
      expect(subject.lines[2]).to include('2306;')
      expect(subject.lines[2]).to include('BELEG-1;')
      expect(subject.lines[2]).to include(';0;')
    end

    it "should include data from journal_with_3_postings" do
      expect(subject.lines[3]).to include('Telefonrechnung;')
      expect(subject.lines[3]).to include('4920;')
      expect(subject.lines[3]).to include('1600;')
      expect(subject.lines[3]).to include('8,40;')
      expect(subject.lines[3]).to include(';S;')
      expect(subject.lines[3]).to include('2406;')
      expect(subject.lines[3]).to include('BELEG-2;')
      expect(subject.lines[3]).to include(';0;')

      expect(subject.lines[4]).to include('Telefonrechnung;')
      expect(subject.lines[4]).to include('1576;')
      expect(subject.lines[4]).to include('1600;')
      expect(subject.lines[4]).to include('1,60;')
      expect(subject.lines[4]).to include(';S;')
      expect(subject.lines[4]).to include(';2406;')
      expect(subject.lines[4]).to include('BELEG-2;')
      expect(subject.lines[4]).to include('0;')
    end
  end

  describe :to_file do
    it "should create CSV file" do
      Dir.mktmpdir do |dir|
        filename = "#{dir}/EXTF_Buchungsstapel.csv"
        export.to_file(filename)

        expect(File).to exist(filename)
      end
    end
  end
end
