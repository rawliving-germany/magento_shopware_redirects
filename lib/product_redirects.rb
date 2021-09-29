# SPDX-FileCopyrightText: 2021 Felix Wolfsteller
#
# SPDX-License-Identifier: AGPL-3.0-or-later

# per product nginx redirect rules
class ProductRedirects
  def self.to_nginx products, url: ''
    products_with_mapping(products).flat_map do |product|
      product.magento_urls.flat_map do |magento_url|
        "rewrite ^/#{magento_url}.*$ #{url}#{product.shopware_url} redirect;"
      end
    end
  end

  def self.products_with_mapping products
    products.select(&:urls_for_magento_and_shopware?)
  end
end

