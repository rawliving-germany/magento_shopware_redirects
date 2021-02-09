# SPDX-FileCopyrightText: 2021 Felix Wolfsteller
#
# SPDX-License-Identifier: AGPL-3.0-or-later

require 'mysql2'

class MagentoDB
  attr_accessor :db_client

  def initialize user, password, dbname
    @db_client = Mysql2::Client.new(
      host: '127.0.0.1',
      port: '3306',
      username: user,
      password: password,
      database: dbname)
  end

  def products
    query = <<~SQL
      SELECT * FROM catalog_product_entity /*LIMIT 10*/;
    SQL
    @db_client.query(query, symbolize_keys: true, as: :hash).map do |row|
      Product.new id_in_magento: row[:entity_id], sku: row[:sku]
    end
  end
end
