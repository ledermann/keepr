# Keepr

This Ruby gem provides a double entry accounting system for use in any Rails application. It stores all the data via ActiveRecord in the SQL database.

[![Build Status](https://github.com/ledermann/keepr/workflows/Test/badge.svg?branch=master)](https://github.com/ledermann/keepr/actions)
[![Code Climate](https://codeclimate.com/github/ledermann/keepr/badges/gpa.svg)](https://codeclimate.com/github/ledermann/keepr)
[![Coverage Status](https://coveralls.io/repos/github/ledermann/keepr/badge.svg?branch=master)](https://coveralls.io/github/ledermann/keepr?branch=master)

## Features

* Journal entries with two or more postings follow the [Double Entry](https://www.accountingcoach.com/blog/what-is-the-double-entry-system) principle
* Accounts (including subaccounts and groups)
* Taxes
* Cost centers
* Balance sheets
* Profit and loss statements
* DATEV exports


## Dependencies

* Ruby 3.1+
* Rails 6.1+ (including Rails 8.0)

## Installation

Add this line to your application's Gemfile:

    gem 'keepr'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install keepr


## Getting started

After installation run the following:

	rails g keepr:migration
	rails db:migrate

This will create the database migration files and add new models.

## Usage
### Account
All accounting entries are stored inside "accounts", per standard accounting
principles. To create an account, use the following format:

	Keepr::Account.create!(number: 27, name: 'Software', kind: :asset)

"kind" is one of following values:

	[asset liability revenue expense forward debtor creditor]

Accounts can have "child" accounts. All entries posted in a child account will
be shown in the "parent" account as well. To create a child account:

	account_1400 = Keepr::Account.create!(number: 1400, name: 'Software', kind: :expense)
	account_14001 = Keepr::Account.create!(number: 14001, name: 'Rails', parent: account_1400 , kind: :expense)

Accounts can be organised inside of groups:

	group = Keepr::Group.create!(is_result: true, target: :liability, name: 'foo')
	Keepr::Account.create!(number: 100, name: 'Trade payable', kind: :liability, keepr_group: group)

Groups also allow a parent/child hierarchy:

	parent_group = Keepr::Group.create!(is_result: true, target: :liability, name: 'foo')
	child_group = parent_group.children.create! name: 'Bar'

### Journal


Simple journal:

    simple_journal = Keepr::Journal.create keepr_postings_attributes: [
      { keepr_account: account_1000, amount: 100.99, side: 'debit' },
      { keepr_account: account_1200, amount: 100.99, side: 'credit' }
    ]


Complex journal:

    complex_journal = Keepr::Journal.create keepr_postings_attributes: [
      { keepr_account: account_4920, amount: 8.40, side: 'debit' },
      { keepr_account: account_1576, amount: 1.60, side: 'debit' },
      { keepr_account: account_1600, amount: 10.00, side: 'credit' }
    ]

Entries can be locked for changing data:

	simple_journal.update! permanent: true


### Account balance
We can get an account balance as follows:

	account_1000.balance

	account_1000.balance(Date.today)

	account_1000.balance(Date.yesterday...Date.today)

### Tax account

	// Create Tax account
	Keepr::Account.create! number: 1776, name: 'Umsatzsteuer 19%', kind: :asset

	tax = Keepr::Tax.create! name: 'USt19',
	                       description: 'Umsatzsteuer 19%',
	                       value: 19.0,
	                       keepr_account: tax_account

	// Create a sale account that links to the tax account
	account = Keepr::Account.new number: 8400,
                                 name: 'Erlöse 19% USt',
                                 kind: :revenue,
                                 keepr_tax: tax




## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Similar projects

* https://github.com/mbulat/plutus
* https://github.com/betterplace/acts_as_account
* https://github.com/steveluscher/bookkeeper
* https://github.com/mstrauss/double-entry-accounting
* https://github.com/logicleague/double_booked
* https://github.com/telent/pacioli
* https://github.com/astrails/deb
* https://github.com/bigfleet/accountable


Copyright (c) 2013-2023 [Georg Ledermann](https://ledermann.dev), released under the MIT license
