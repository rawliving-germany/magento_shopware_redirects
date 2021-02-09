# SPDX-FileCopyrightText: 2021 Felix Wolfsteller
#
# SPDX-License-Identifier: AGPL-3.0-or-later

require 'mysql2'

class ShopwareDB
  attr_accessor :db_client

  def initialize user, password, dbname
    @db_client = Mysql2::Client.new(
      host: '127.0.0.1',
      port: '3306',
      username: user,
      password: password,
      database: dbname)
  end

  # identifies products already in memstore (by the sku) and
  # populates shopware-specific fields like id.
  # if product not yet in memstore, create it
  def merge_products products_memstore
    query = <<~SQL
      SELECT * FROM s_articles_details /*LIMIT 10*/;
    SQL
    @db_client.query(query, symbolize_keys: true, as: :hash).map do |row|
      product = products_memstore.find_or_create_by attr: :sku, value: row[:ordernumber]
      product.id_in_shopware = row[:articleID]
      #Product.new id_in_shopware: row[:articleID], sku: row[:ordernumber]
    end
  end
end
