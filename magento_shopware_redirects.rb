#!/usr/bin/env ruby

# SPDX-FileCopyrightText: 2021 Felix Wolfsteller
#
# SPDX-License-Identifier: AGPL-3.0-or-later

require 'optparse'

require_relative './lib/magento_db.rb'
require_relative './lib/magento_products.rb'
require_relative './lib/memstore.rb'
require_relative './lib/product.rb'
require_relative './lib/redirects.rb'
require_relative './lib/shopware_db.rb'
require_relative './lib/shopware_products.rb'

db_conf = {
  username: nil,
  password: nil,
  magentodb: nil,
  shopwaredb: nil
}

option_parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [OPTIONS]"
  opts.separator ""

  opts.separator "Shopware configuration"
  opts.on("", "--shopwaredb DATABASENAME", 'Connect to a shopware5 database called DATABASENAME') do |shopwaredb|
    db_conf[:shopwaredb] = shopwaredb
  end

  opts.separator "Magento configuration"
  opts.on("", "--magentodb DATABASENAME", 'Connect to a magento2 database called DATABASENAME') do |magentodb|
    db_conf[:magentodb] = magentodb
  end

  opts.separator "General options"
  opts.on("", "--dbuser DATABASEUSER", 'Use DATABASEUSER to connect to the databases') do |dbuser|
    db_conf[:username] = dbuser
  end
  opts.on("", "--dbpass DATABASEPASSWORD", 'Use DATABASEPASSWORD to connect to the databases') do |dbpass|
    db_conf[:password] = dbpass
  end

  opts.on("-h", "--help", 'Show help and exit') do
    puts opts
    exit 0
  end
end
option_parser.parse!

if db_conf.values.include? nil
  STDERR.puts "Please provide all database-related options"
  puts db_conf.inspect
  puts option_parser
  exit 1
end

magento_db = MagentoDB.new(db_conf[:username], db_conf[:password], db_conf[:magentodb])

magento_products = magento_db.products

mem = Memstore.new(Product)
mem.add_all magento_products

shopware_db = ShopwareDB.new(db_conf[:username], db_conf[:password], db_conf[:shopwaredb])
shopware_products = shopware_db.merge_products mem

puts mem.objs.select(&:in_magento_and_shopware?).count

#puts mem.objs.inspect

puts Redirects.to_nginx

# Exit with grace
exit 0
