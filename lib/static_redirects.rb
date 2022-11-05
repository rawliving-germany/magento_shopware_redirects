# SPDX-FileCopyrightText: 2021 Felix Wolfsteller
#
# SPDX-License-Identifier: AGPL-3.0-or-later

# static nginx redirect rules
class StaticRedirects
  def self.to_nginx
    self.static_rules
  end

  def self.static_rules
    self.affiliate_redirect + self.search_redirects
  end

  def self.affiliate_redirect
    rewrite_rule = <<~NGINX
      if ($query_string ~* "^a_aid=(?<affid>.*)$") {
        rewrite ^(.*)$ $1?Partner=$affid? redirect;
      }
    NGINX

    rewrite_rule
  end

  def self.search_redirects
   rewrite_rule = <<~NGINX
     rewrite ^/catalogsearch/result/index/?(?<searchstring>.*)$ /search?sSearch=$searchstring redirect;
     rewrite ^/catalogsearch/result?(?<searchstring>.*)$ /search?sSearch=$searchstring redirect;
   NGINX

   rewrite_rule
  end
end
