# Keepr

This Ruby gem provides a double entry accounting system for use in any Rails application. It stores all the data via ActiveRecord in the SQL database.

[![Build Status](https://travis-ci.org/ledermann/keepr.svg?branch=master)](https://travis-ci.org/ledermann/keepr)
[![Code Climate](https://codeclimate.com/github/ledermann/keepr/badges/gpa.svg)](https://codeclimate.com/github/ledermann/keepr)
[![Coverage Status](https://coveralls.io/repos/ledermann/keepr/badge.svg?branch=master)](https://coveralls.io/r/ledermann/keepr?branch=master)

## Features

* Journal entries with two or more postings
* Accounts (including subaccounts and groups)
* Tax
* Cost center
* Balance sheet
* Profit and loss statement
* DATEV export


## Dependencies

* Ruby 2.0.0 or later
* Rails 4.1 or newer (including Rails 5.x)


## Installation

Add this line to your application's Gemfile:

    gem 'keepr'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install keepr


## Usage

TODO: Write usage instructions here


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


Copyright (c) 2013-2018 [Georg Ledermann](http://www.georg-ledermann.de), released under the MIT license
