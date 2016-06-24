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
require 'keepr/export'
require 'keepr/active_record_extension'

class ActiveRecord::Base
  include Keepr::ActiveRecordExtension
end
