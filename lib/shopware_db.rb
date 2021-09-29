# SPDX-FileCopyrightText: 2021 Felix Wolfsteller
#
# SPDX-License-Identifier: AGPL-3.0-or-later

# Fetch product information in magento database and operate on memstore
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

  def add_urls products_memstore
    sql_query = <<~SQL
      SELECT * FROM s_core_rewrite_urls WHERE org_path LIKE '%sViewport=detail&sArticle=%'
    SQL
    s_core_rewrite_urls = query(sql_query)

    s_core_rewrite_urls.each do |url_row|
      article_id = url_row[:org_path][/\d+/]
      if article_id.to_s != ""
        article_id = article_id.to_i
        product = products_memstore.find_with(id_in_shopware: article_id)
        if product
          product.shopware_url = url_row[:path]
        else
          MagentoShopwareRedirect::logger.warn "product (shopware id) #{article_id.inspect} not found"
        end
      end
    end
  end
end
