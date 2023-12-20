# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/migration'

module Keepr
  class MigrationGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    desc 'Generates migration for keepr'
    source_root File.expand_path('templates', __dir__)

    def create_migration_file
      migration_template 'migration.rb', 'db/migrate/keepr_migration.rb'
    end

    def self.next_migration_number(dirname)
      if ActiveRecord.timestamped_migrations
        Time.now.utc.strftime('%Y%m%d%H%M%S')
      else
        format('%.3d', (current_migration_number(dirname) + 1))
      end
    end
  end
end
