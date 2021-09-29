#!/usr/bin/env ruby

# SPDX-FileCopyrightText: 2021 Felix Wolfsteller
#
# SPDX-License-Identifier: AGPL-3.0-or-later

require 'optparse'

require_relative './lib/magento_shopware_redirect'

require_relative './lib/db.rb'
require_relative './lib/db_credentials.rb'
require_relative './lib/magento_db.rb'
require_relative './lib/magento_products.rb'
require_relative './lib/memstore.rb'
require_relative './lib/product.rb'
require_relative './lib/product_redirects.rb'
require_relative './lib/static_redirects.rb'
require_relative './lib/shopware_db.rb'
require_relative './lib/shopware_products.rb'

db_conf = {
  magentodb:  DBCredentials.new(host: '127.0.0.1', port: 3306),
  shopwaredb: DBCredentials.new(host: '127.0.0.1', port: 3306),
  limit: -1
}

url_prefix = ''

option_parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [OPTIONS]"
  opts.separator ""

  opts.separator "Shopware configuration"
  opts.on("", "--shopwaredb DATABASENAME", 'Connect to a shopware5 database called DATABASENAME') do |shopwaredb|
    db_conf[:shopwaredb].databasename = shopwaredb
  end

  opts.separator "Magento configuration"
  opts.on("", "--magentodb DATABASENAME", 'Connect to a magento2 database called DATABASENAME') do |magentodb|
    db_conf[:magentodb].databasename = magentodb
  end

  opts.separator "General options"
  opts.on("", "--dbuser DATABASEUSER", 'Use DATABASEUSER to connect to the databases') do |dbuser|
    db_conf[:shopwaredb].username = dbuser
    db_conf[:magentodb].username  = dbuser
  end
  opts.on("", "--dbpass DATABASEPASSWORD", 'Use DATABASEPASSWORD to connect to the databases') do |dbpass|
    db_conf[:shopwaredb].password = dbpass
    db_conf[:magentodb].password = dbpass
  end

  opts.on("-l", "--limit LIMIT", Integer, 'For debugging purposes, limit the SQL query (will result in incomplete data)') do |l|
    DB::limit = l.abs
    db_conf[:limit] = l
  end

  opts.on("-u", "--url URL", 'Shopware URL to prefix to the redirects (your shops url)') do |url|
    url_prefix = url
  end

  opts.on("-h", "--help", 'Show help and exit') do
    puts opts
    exit 0
  end
  opts.on("-v", "--verbose", 'Verbose logging') do |v|
    MagentoShopwareRedirect::logger.level = Logger::DEBUG
  end
end
option_parser.parse!

if ! (db_conf[:magentodb].given? && db_conf[:shopwaredb].given?)
  STDERR.puts "Please provide all database-related options"
  puts db_conf.inspect
  puts option_parser
  exit 1
end

if db_conf[:limit] > 0
  MagentoShopwareRedirect::logger.warn "Limit set to #{db_conf[:limit]} - will result in incomplete data"
end

magento_db = MagentoDB.new(db_conf[:magentodb])

magento_products = magento_db.products

mem = Memstore.new(Product)
mem.add_all magento_products

shopware_db = ShopwareDB.new(db_conf[:shopwaredb])
shopware_products = shopware_db.merge_products mem

puts mem.objs.select(&:in_magento_and_shopware?).count

#puts mem.objs.inspect

puts Redirects.to_nginx

# Exit with grace
exit 0
