class Keepr::AccountExport
  def initialize(accounts, header_options={})
    @accounts = accounts
    @header_options = header_options
  end

  def to_s
    export.to_s
  end

  def to_file(filename)
    export.to_file(filename)
  end

private

  def export
    export = Datev::AccountExport.new(@header_options)

    @accounts.reorder(:number).each do |account|
      unless account.debtor? || account.creditor?
        export << to_datev(account)
      end
    end

    export
  end

  def to_datev(account)
    { 'Konto'               => account.number,
      'Kontenbeschriftung'  => account.name.slice(0,40)
    }
  end
end
