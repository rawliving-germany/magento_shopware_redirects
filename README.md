<!--
SPDX-FileCopyrightText: 2020 Felix Wolfsteller
SPDX-License-Identifier: AGPL-3.0-or-later
-->
# magento-shopware-redirects

Scripts to create redirect definitions for nginx from magento 2 URLs to
shopware 5 URLs.
As the script is tied to one specific migration, a number of magento settings
are assumed. Within magento there are multiple ways to influence the generated
urls (SEO etc.). The value of these settings are totally ignored.

Ideally, you would iterate over the sitemap, but apparently in our use case the
sitemap generation is messed up.

Magentos URLs reflect the productId in our case, but we have access to the SKU.

It will only work with MySQL/MariaDB installations.

## Scope

Following URLs should be redirected:

  * search queries (for some reason some of our search queries are google indexed pretty well)
    * https://shopware/search?sSearch=searchterm
  * categories
  * products:
    https://SHOP/catalog/product/view/id/3334/*
    https://SHOP/catalog/product/view/id/3334/s/*
    https://SHOP/catalog/product/view/id/3334/s/hefeflocken-auf-malzbasis-bio-250g/
    https://SHOP/catalog/product/view/id/3334/s/hefeflocken-auf-malzbasis-bio-250g.html
    but sometimes:
    https://SHOP/nama-gersten-miso-bio-250g.html
-> 
  * static pages

However, admin-access path should NOT be redirected.
  

## Usage

run `magento_shopware_redirects --help`

It is assumed that magento and shopware share the same database server.

## Knowledgebase

  * Adobe Magento Catalog URL documentation: https://docs.magento.com/user-guide/catalog/catalog-urls.html
  * In case you forgot, 302 redirects are temporary (safe to try), while 301
    redirects (permament) will make your browser not hitting the original URL
    ever again.
  * using connection strings might make db conf easier: `DATABASE_URL=mysql2://sql_user:sql_pass@sql_host_name:port/sql_db_name?option1=value1&option2=value2`.

#### Memstore

A stupid multi-index memory store is implemented in
[lib/memstore.rb](lib/memstore.rb) .

### Database

#### Infos in Magento DB

  * `sku` in `catalag_product_entity`
  * there are shortforms of the articles in two varchar eav-attributes

#### Infos in Shopware DB

  * `sku` is in `s_articles_details` (`articleID` / `ordernumber`)
  * (relative) product URLs are in `s_core_rewrite_urls`, but need to be
    downcased. Find from product id via `org_path` (e.g.
`sViewport=detail&sArticle=122`).

## License

Code is copyright 2021 Felix Wolfsteller and released under the AGPLv3+ which is
included in the [`LICENSE`](LICENSE) file in full text. The project should
become [reuse](https://reuse.software) compliant.

However, these are only notes and scripts for a specific usecase. If you have a
(tiny) budget and need or some ideas about improvements, just get in contact.
