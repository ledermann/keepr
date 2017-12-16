module Keepr::ActiveRecordExtension
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def has_one_keepr_account
      has_one :keepr_account, class_name: 'Keepr::Account', as: :accountable, dependent: :restrict_with_error
      has_many :keepr_postings, class_name: 'Keepr::Posting', through: :keepr_account, dependent: :restrict_with_error
    end

    def has_many_keepr_accounts
      has_many :keepr_accounts, class_name: 'Keepr::Account', as: :accountable, dependent: :restrict_with_error
      has_many :keepr_postings, class_name: 'Keepr::Posting', through: :keepr_accounts, dependent: :restrict_with_error
    end

    def has_keepr_journals
      has_many :keepr_journals, class_name: 'Keepr::Journal', as: :accountable, dependent: :restrict_with_error

      class_eval <<-EOT
        def keepr_booked?
          keepr_journals.exists?
        end

        scope :keepr_unbooked, -> {
                                    joins('LEFT JOIN keepr_journals ON keepr_journals.accountable_id = #{table_name}.id AND keepr_journals.accountable_type="#{base_class.name}"').
                                    where('keepr_journals.id' => nil)
                                  }
        scope :keepr_booked,   -> { joins(:keepr_journals) }
      EOT
    end

    def has_keepr_postings
      has_many :keepr_postings, class_name: 'Keepr::Posting', as: :accountable, dependent: :restrict_with_error
    end
  end
end
