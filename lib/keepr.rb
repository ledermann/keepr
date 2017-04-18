require 'ancestry'
require 'datev'

require 'keepr/version'
require 'keepr/group'
require 'keepr/groups_creator'
require 'keepr/cost_center'
require 'keepr/tax'
require 'keepr/account'
require 'keepr/posting'
require 'keepr/journal'
require 'keepr/journal_export'
require 'keepr/account_export'
require 'keepr/contact_export'
require 'keepr/active_record_extension'

class ActiveRecord::Base
  include Keepr::ActiveRecordExtension
end

Keepr::MIGRATION_BASE_CLASS = if ActiveRecord::VERSION::MAJOR >= 5
  ActiveRecord::Migration[5.0]
else
  ActiveRecord::Migration
end
