# frozen_string_literal: true

class Ledger < ActiveRecord::Base
  has_one_keepr_account
end
