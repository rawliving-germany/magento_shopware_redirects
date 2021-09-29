# SPDX-FileCopyrightText: 2021 Felix Wolfsteller
#
# SPDX-License-Identifier: AGPL-3.0-or-later

require 'logger'

module MagentoShopwareRedirect
  def self.logger
    @@logger ||= Logger.new(STDERR)
  end
end
