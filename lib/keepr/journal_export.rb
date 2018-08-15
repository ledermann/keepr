# frozen_string_literal: true

class Keepr::JournalExport
  def initialize(journals, header_options = {}, &block)
    @journals = journals
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
    export = Datev::BookingExport.new(@header_options)

    @journals.includes(keepr_postings: :keepr_account).reorder(:date, :id).each do |journal|
      to_datev(journal).each do |hash|
        export << hash
      end
    end

    export
  end

  def to_datev(journal)
    main_posting = journal.keepr_postings.find { |p| p.keepr_account.debtor? || p.keepr_account.creditor? }
    main_posting ||= journal.keepr_postings.max_by(&:amount)

    journal.keepr_postings.sort_by { |p| [p.side == main_posting.side ? 1 : 0, -p.amount] }.map do |posting|
      next if posting == main_posting

      {
        'Umsatz (ohne Soll/Haben-Kz)'    => posting.amount,
        'Soll/Haben-Kennzeichen'         => 'S',
        'Konto'                          => posting.debit?  ? posting.keepr_account.number : main_posting.keepr_account.number,
        'Gegenkonto (ohne BU-Schlüssel)' => posting.credit? ? posting.keepr_account.number : main_posting.keepr_account.number,
        'BU-Schlüssel'                   => '40', # Steuerautomatik deaktivieren
        'Belegdatum'                     => journal.date,
        'Belegfeld 1'                    => journal.number,
        'Buchungstext'                   => journal.subject.slice(0, 60),
        'Festschreibung'                 => journal.permanent
      }.merge(@block ? @block.call(posting) : {})
    end.compact
  end
end
