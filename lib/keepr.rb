require 'ancestry'

require 'keepr/version'
require 'keepr/account'
require 'keepr/posting'
require 'keepr/journal'
require 'keepr/chart'
require 'keepr/active_record_extension'

class ActiveRecord::Base
  include Keepr::ActiveRecordExtension
end
