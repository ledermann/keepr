# frozen_string_literal: true

class Keepr::AccountExport
  def initialize(accounts, header_options = {}, &block)
    @accounts = accounts
    @header_options = header_options
    @block = block
  end

  delegate :to_s, :to_file,
           to: :export

  private

  def export
    export = Datev::AccountExport.new(@header_options)

    @accounts.reorder(:number).each do |account|
      export << to_datev(account) unless account.debtor? || account.creditor?
    end

    export
  end

  def to_datev(account)
    {
      'Konto'              => account.number,
      'Kontenbeschriftung' => account.name.slice(0, 40)
    }.merge(@block ? @block.call(account) : {})
  end
end
