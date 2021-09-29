# SPDX-FileCopyrightText: 2021 Felix Wolfsteller
#
# SPDX-License-Identifier: AGPL-3.0-or-later

class Product
  attr_accessor :id_in_shopware, :id_in_magento, :name, :sku, :shopware_url, :magento_urls

  def initialize id_in_magento: nil, id_in_shopware: nil, name: nil, sku: nil
    @id_in_magento  = id_in_magento
    @id_in_shopware = id_in_shopware
    @name = name
    @sku  = sku
  end

  def in_magento_and_shopware?
    in_magento? && in_shopware?
  end

  def in_magento?
    @id_in_magento
  end

  def in_shopware?
    @id_in_shopware
  end

  def urls_for_magento_and_shopware?
    @shopware_url && @magento_urls
  end
end
