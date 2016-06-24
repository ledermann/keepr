class Keepr::Export
  def initialize(journals, header_options={})
    @journals = journals
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
    export = Datev::Export.new(@header_options)

    @journals.includes(:keepr_postings).each do |journal|
      main_posting = journal.keepr_postings.sort_by(&:amount).last

      journal.keepr_postings.each do |posting|
        next if posting == main_posting

        export << {
          'Umsatz (ohne Soll/Haben-Kz)'    => posting.amount,
          'Soll/Haben-Kennzeichen'         => posting.debit? ? 'S' : 'H',
          'Konto'                          => posting.keepr_account.number,
          'Gegenkonto (ohne BU-Schlüssel)' => main_posting.keepr_account.number,
          'Belegdatum'                     => journal.date,
          'Belegfeld 1'                    => journal.number,
          'Buchungstext'                   => journal.subject,
          'Festschreibung'                 => journal.permanent
        }
      end
    end

    export
  end
end
