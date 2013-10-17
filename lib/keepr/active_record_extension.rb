module Keepr::ActiveRecordExtension
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def has_keepr_account
      has_one :keepr_account, :class_name => 'Keepr::Account', :as => :accountable
    end

    def is_keepr_accountable
      has_many :keepr_journals, :class_name => 'Keepr::Journal', :as => :accountable

      class_eval <<-EOT
        def keepr_booked?
          keepr_journals.exists?
        end
      EOT
    end

    def belongs_to_default_keepr_account
      belongs_to :default_keepr_account, :class_name => 'Keepr::Account'
    end
  end
end
