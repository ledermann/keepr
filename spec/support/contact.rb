# frozen_string_literal: true

class Contact < ActiveRecord::Base
  has_many_keepr_accounts
end
