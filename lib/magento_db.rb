# SPDX-FileCopyrightText: 2021 Felix Wolfsteller
#
# SPDX-License-Identifier: AGPL-3.0-or-later

# Fetch product information in magento database and operate on memstore
class MagentoDB < DB

  def products
    sql_query = <<~SQL
      SELECT * FROM catalog_product_entity #{limit};
    SQL
    query(sql_query).map do |row|
      Product.new id_in_magento: row[:entity_id], sku: row[:sku]
    end
  end

  def add_urls product_memstore
    sql_query = <<~SQL
      SELECT * FROM catalog_product_entity_varchar
        WHERE attribute_id IN (SELECT attribute_id FROM eav_attribute WHERE attribute_code IN ('url_key', 'url_path'))
    SQL

    query(sql_query).each do |row|
      product = product_memstore.find_by attr: :id_in_magento, value: row[:entity_id]
      if product.nil?
        MagentoShopwareRedirect::logger.info "magento: product URL found, but product info missing for #{row.inspect}"
        next
      end
      (product.magento_urls ||= []) << row[:value]
    end

    # TODO evaluate whether we want to always add e.g.
    # https://SHOP/catalog/product/view/id/3334/s/*

    product_memstore.objs.select {|p| p.magento_urls.join.strip == ''}.each do |product|
      MagentoShopwareRedirect::logger.warn "missing url for #{product}"
    end
  end
end

