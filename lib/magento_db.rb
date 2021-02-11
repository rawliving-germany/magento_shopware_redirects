# SPDX-FileCopyrightText: 2021 Felix Wolfsteller
#
# SPDX-License-Identifier: AGPL-3.0-or-later

class MagentoDB < DB

  def products
    sql_query = <<~SQL
      SELECT * FROM catalog_product_entity #{limit};
    SQL
    query(sql_query).map do |row|
      Product.new id_in_magento: row[:entity_id], sku: row[:sku]
    end
  end
end
