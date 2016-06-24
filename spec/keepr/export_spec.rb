require 'spec_helper'

describe Keepr::Export do
  let(:ust) { Keepr::Tax.create! :name => 'USt19', :value => 19.0, :keepr_account => account_1776 }
  let(:vst) { Keepr::Tax.create! :name => 'VSt19', :value => 19.0, :keepr_account => account_1576 }

  let(:account_1000)  { FactoryGirl.create :account, :number => 1000, :kind => :asset     }
  let(:account_1200)  { FactoryGirl.create :account, :number => 1200, :kind => :asset     }
  let(:account_1576)  { FactoryGirl.create :account, :number => 1576, :kind => :asset     }
  let(:account_1776)  { FactoryGirl.create :account, :number => 1776, :kind => :liability }
  let(:account_1600)  { FactoryGirl.create :account, :number => 1600, :kind => :liability }
  let(:account_1718)  { FactoryGirl.create :account, :number => 1718, :kind => :liability, :keepr_tax => ust }
  let(:account_4920)  { FactoryGirl.create :account, :number => 4920, :kind => :expense,   :keepr_tax => vst }
  let(:account_8400)  { FactoryGirl.create :account, :number => 8400, :kind => :revenue,   :keepr_tax => ust }

  let(:account_10000) { FactoryGirl.create :account, :number => 10000, :kind => :debtor   }

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

    def booking_lines
      subject.lines[2..-1]
    end

    it "should return CSV lines" do
      expect(subject.lines.count).to eq(2)
      subject.lines.each { |line| expect(line).to include(';') }
    end

    it "should include header data" do
      expect(subject.lines[0]).to include('1234567;')
      expect(subject.lines[0]).to include('78901;')
      expect(subject.lines[0]).to include('20160601;20160630;')
      expect(subject.lines[0]).to include('Keepr-Buchungen;')
    end

    context "Journal without tax" do
      let!(:journal_without_tax) do
        Keepr::Journal.create! :number                    => 'BELEG-1',
                               :subject                   => 'Geldautomat',
                               :date                      => Date.new(2016,06,23),
                               :keepr_postings_attributes => [
                                 { :keepr_account => account_1000, :amount => 105, :side => 'debit' },
                                 { :keepr_account => account_1200, :amount => 105, :side => 'credit' }
                               ]
      end

      it "should include data" do
        expect(booking_lines.count).to eq(1)

        expect(booking_lines[0]).to include('Geldautomat;')
        expect(booking_lines[0]).to include('1000;1200;')
        expect(booking_lines[0]).to include('105,00;')
        expect(booking_lines[0]).to include(';S;')
        expect(booking_lines[0]).to include('2306;')
        expect(booking_lines[0]).to include('BELEG-1;')
        expect(booking_lines[0]).to include(';0;')
      end
    end

    context "Journal with tax" do
      let!(:journal_with_tax) do
        Keepr::Journal.create! :number                    => 'BELEG-2',
                               :subject                   => 'Telefonrechnung',
                               :date                      => Date.new(2016,06,24),
                               :keepr_postings_attributes => [
                                 { :keepr_account => account_4920, :amount =>  8.40, :side => 'debit' },
                                 { :keepr_account => account_1576, :amount =>  1.60, :side => 'debit' },
                                 { :keepr_account => account_1600, :amount => 10.00, :side => 'credit' }
                               ]
      end

      it "should include data" do
        expect(booking_lines.count).to eq(2)

        expect(booking_lines[0]).to include('Telefonrechnung;')
        expect(booking_lines[0]).to include('4920;1600;')
        expect(booking_lines[0]).to include('8,40;')
        expect(booking_lines[0]).to include(';S;')
        expect(booking_lines[0]).to include('2406;')
        expect(booking_lines[0]).to include('BELEG-2;')
        expect(booking_lines[0]).to include(';0;')

        expect(booking_lines[1]).to include('Telefonrechnung;')
        expect(booking_lines[1]).to include('1576;1600;')
        expect(booking_lines[1]).to include('1,60;')
        expect(booking_lines[1]).to include(';S;')
        expect(booking_lines[1]).to include('2406;')
        expect(booking_lines[1]).to include('BELEG-2;')
        expect(booking_lines[1]).to include(';0;')
      end
    end

    context "Journal with debtor" do
      let!(:journal_with_debtor) do
        Keepr::Journal.create! :number                    => 'BELEG-3',
                               :subject                   => 'Warenverkauf mit Anzahlung',
                               :date                      => Date.new(2016,06,25),
                               :keepr_postings_attributes => [
                                 { :keepr_account => account_10000, :amount => 4760.00, :side => 'debit'  },
                                 { :keepr_account => account_1718,  :amount => 1000.00, :side => 'debit'  },
                                 { :keepr_account => account_1776,  :amount =>  190.00, :side => 'debit'  },

                                 { :keepr_account => account_8400,  :amount => 5000.00, :side => 'credit' },
                                 { :keepr_account => account_1776,  :amount =>  950.00, :side => 'credit' }
                               ]
      end

      it "should include data" do
        expect(booking_lines.count).to eq(4)

        expect(booking_lines[1]).to include('Warenverkauf mit Anzahlung;')
        expect(booking_lines[0]).to include('8400;10000;')
        expect(booking_lines[0]).to include('5000,00;')
        expect(booking_lines[0]).to include(';H;')
        expect(booking_lines[0]).to include('2506;')
        expect(booking_lines[0]).to include('BELEG-3;')
        expect(booking_lines[0]).to include(';0;')

        expect(booking_lines[1]).to include('Warenverkauf mit Anzahlung;')
        expect(booking_lines[1]).to include('1776;10000;')
        expect(booking_lines[1]).to include('950,00;')
        expect(booking_lines[1]).to include(';H;')
        expect(booking_lines[1]).to include('2506;')
        expect(booking_lines[1]).to include('BELEG-3;')
        expect(booking_lines[1]).to include(';0;')

        expect(booking_lines[2]).to include('Warenverkauf mit Anzahlung;')
        expect(booking_lines[2]).to include('1718;10000;')
        expect(booking_lines[2]).to include('1000,00;')
        expect(booking_lines[2]).to include(';S;')
        expect(booking_lines[2]).to include('2506;')
        expect(booking_lines[2]).to include('BELEG-3;')
        expect(booking_lines[2]).to include(';0;')

        expect(booking_lines[3]).to include('Warenverkauf mit Anzahlung;')
        expect(booking_lines[3]).to include('1776;10000;')
        expect(booking_lines[3]).to include('190,00;')
        expect(booking_lines[3]).to include(';S;')
        expect(booking_lines[3]).to include('2506;')
        expect(booking_lines[3]).to include('BELEG-3;')
        expect(booking_lines[3]).to include(';0;')
      end
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
