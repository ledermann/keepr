# frozen_string_literal: true

class Keepr::ContactExport
  def initialize(accounts, header_options = {}, &block)
    raise ArgumentError unless block_given?

    @accounts = accounts
    @header_options = header_options
    @block = block
  end

  def to_s
    export.to_s
  end

  def to_file(filename)
    export.to_file(filename)
  end

  private

  def export
    export = Datev::ContactExport.new(@header_options)

    @accounts.reorder(:number).each do |account|
      export << to_datev(account) if account.debtor? || account.creditor?
    end

    export
  end

  def to_datev(account)
    { 'Konto' => account.number }.merge(@block.call(account))
  end
end
