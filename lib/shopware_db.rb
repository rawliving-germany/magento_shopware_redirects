# SPDX-FileCopyrightText: 2021 Felix Wolfsteller
#
# SPDX-License-Identifier: AGPL-3.0-or-later

class ShopwareDB < DB

  # identifies products already in memstore (by the sku) and
  # populates shopware-specific fields like id.
  # if product not yet in memstore, create it
  def merge_products products_memstore
    sql_query = <<~SQL
      SELECT * FROM s_articles_details #{limit};
    SQL
    query(sql_query).each do |row|
      product = products_memstore.find_or_create_by attr: :sku, value: row[:ordernumber]
      product.id_in_shopware = row[:articleID]
      #Product.new id_in_shopware: row[:articleID], sku: row[:ordernumber]
    end
  end
end
