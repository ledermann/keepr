require 'csv'

module Keepr
  class Chart
    def initialize(filename)
      @filename = filename

      raise ArgumentError unless File.exists?(filename_with_path)
    end

    def load!
      CSV.foreach(filename_with_path, :encoding => 'iso-8859-1', :col_sep => ';', :headers => true) do |row|
        number, name, kind = row[0], row[1], row[2]

        Keepr::Account.find_or_create_by(number: number) do |account|
          account.name = name
          account.kind = kind
        end
      end
    end

  private
    def filename_with_path
      File.dirname(__FILE__) + "/../data/#{@filename}.csv"
    end
  end
end
