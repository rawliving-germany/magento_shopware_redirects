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
    * __magento:__  https://magento/s
    * __shopware:__ https://shopware/search?sSearch=searchterm
    * --> **dropped that idea**
  * categories
    * --> **manually with some redirect plugin**
  * products:
    https://SHOP/catalog/product/view/id/3334/*
    https://SHOP/catalog/product/view/id/3334/s/*
    https://SHOP/catalog/product/view/id/3334/s/hefeflocken-auf-malzbasis-bio-250g/
    https://SHOP/catalog/product/view/id/3334/s/hefeflocken-auf-malzbasis-bio-250g.html
    but sometimes:
    https://SHOP/nama-gersten-miso-bio-250g.html
    * --> that we will do
  * static pages
    * --> **not yet implemented**
  * ~~images: nope, we dont do that~~

However, admin-access path should NOT be redirected.

  * affiliate links (probably from plugin):
    * __magento:__  https://magento/product?a_aid=9182b8723
    * __shopware:__ https://shopware/product?sPartner=9182b8723
    * apparently, the partner-id is fine, will not change/can be defined
      manually.

## Usage

run `magento_shopware_redirects --help`

It is assumed that magento and shopware share the same database server.

## Knowledgebase

  * Adobe Magento Catalog URL documentation: https://docs.magento.com/user-guide/catalog/catalog-urls.html
  * In case you forgot, 302 redirects are temporary (safe to try), while 301
    redirects (permanent) will make your browser not hitting the original URL
    ever again.
  * nginx models this as `rewrite FROM TO redirect|permamanent;` (last parameter)
  * using connection strings might make db conf easier: `DATABASE_URL=mysql2://sql_user:sql_pass@sql_host_name:port/sql_db_name?option1=value1&option2=value2`.
  * Delegation and Forwardable is discussed here: https://blog.appsignal.com/2019/04/30/ruby-magic-hidden-gems-delegator-forwardable.html

#### Memstore

A stupid multi-index memory store is implemented in
[lib/memstore.rb](lib/memstore.rb) .
Some basic tests included in `test/`.

The idea is to keep hashtables that allow quick access to objects by attribute,
think of half-memoized `objects.select{|obj| obj.attribute == attribute_value}`.
Alternative would be an external dependency and e.g. an in-memory sqlite3 or
berkely-db.


### Database

#### Infos in Magento DB

  * `sku` in `catalag_product_entity`
  * there are shortforms of the articles in two varchar eav-attributes
  * specific product URLs in `eav_attributes` `url_key` and `url_path`.
    * per product: `catalog_product_entity_varchar` (`.value`) where
      `attribute_id` matches these and `entity_id` matches the products
`entity_id`

#### Infos in Shopware DB

  * `sku` is in `s_articles_details` (`articleID` / `ordernumber`)
  * (relative) product URLs are in `s_core_rewrite_urls`, but need to be
    downcased. Find from product id via `org_path` (e.g. `sViewport=detail&sArticle=122`).
  * configurable articles have multiple s_article_details for the same articleId

## "Architecture"
(There was no prior architectural work, so this is rather a "what grew where"):


### Code map

```
.
├── lib
│   ├── db_credentials.rb            # PORO for the two DB credentials
│   ├── db.rb                        # DB driver (mysql shim) and base class
│   ├── magento_db.rb                # Queries against magento DB and memstore
│   ├── magento_shopware_redirect.rb # Module-wide functionality and conf
│   ├── memstore.rb                  # in-mem selfbuild multi-directional cache
│   ├── product.rb                   # Class for in-mem abstraction of a Product
│   ├── product_redirects.rb         # Per Product Nginx redirect rule strings
│   ├── shopware_db.rb               # Queries against shopware DB and memstore
│   └── static_redirects.rb          # Static (non-product) redirect rule(s)
├── magento_shopware_redirects.rb    # MAIN entry/script/exec
└── test                             # Tests
    └── test_memstore.rb             # Memstore Test
```

## License

Code is copyright 2021,2022 Felix Wolfsteller and released under the AGPLv3+ which is
included in the [`LICENSE`](LICENSE) file in full text. The project should
become [reuse](https://reuse.software) compliant.

However, these are only notes and scripts for a specific usecase. If you have a
(tiny) budget and need or some ideas about improvements, just get in contact.
