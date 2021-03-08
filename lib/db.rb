# SPDX-FileCopyrightText: 2021 Felix Wolfsteller
#
# SPDX-License-Identifier: AGPL-3.0-or-later

require 'mysql2'

class DB
  attr_accessor :db_client
  @@limit = 0

  def initialize db_credentials
    @db_client = Mysql2::Client.new(
      host:     db_credentials.host || '127.0.0.1',
      port:     db_credentials.port || '3306',
      username: db_credentials.username,
      password: db_credentials.password,
      database: db_credentials.databasename)
  end

  def self.limit= limit
    @@limit = limit.abs
  end

  def limit
    if @@limit > 0
      "LIMIT #{@@limit.to_s}"
    end
  end

  def query sql_query
    # EVAL do we add @@limit here?
    @db_client.query(sql_query, symbolize_keys: true, as: :hash)
  end
end
