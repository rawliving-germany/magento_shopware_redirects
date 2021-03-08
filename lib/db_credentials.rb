# SPDX-FileCopyrightText: 2021 Felix Wolfsteller
#
# SPDX-License-Identifier: AGPL-3.0-or-later

class DBCredentials
  attr_accessor :username, :password, :host, :port, :databasename, :database

  def initialize username: nil, password: nil, host: nil, port: nil, databasename: nil, databasetype: :mysql
    @username = username
    @password = password
    @host     = host
    @port     = port
    @databasename = databasename
    @databasetype = databasetype
  end

  def given?
    @databasename && @username && @password
  end
end
