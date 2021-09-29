# SPDX-FileCopyrightText: 2021 Felix Wolfsteller
#
# SPDX-License-Identifier: AGPL-3.0-or-later

class StaticRedirects
  def self.to_nginx
    self.static_rules
  end

  def self.static_rules
    self.affiliate_redirect
  end

  def self.affiliate_redirect
    rewrite_rule = <<~NGINX
      if ($query_string ~* "^a_aid=(?<affid>.*)$") {
        rewrite ^(.*)$ $1Partner=$affid? redirect;
      }
    NGINX

    rewrite_rule
  end
end

