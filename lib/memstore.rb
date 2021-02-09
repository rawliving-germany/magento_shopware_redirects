# SPDX-FileCopyrightText: 2021 Felix Wolfsteller
#
# SPDX-License-Identifier: AGPL-3.0-or-later

require 'forwardable'

# Hash-index array of stuff that is assumed to be rather immutable (no
# live-reindexing)
class Memstore
  extend Forwardable

  def_delegators :@objs, :count, :size

  attr_reader :objs

  def initialize obj_class
    @obj_class = obj_class
    @objs = []
    @idxs = {}
  end

  def add_all array_of_objs
    @objs |= array_of_objs
    reindex!
  end

  # Assuming uniqe index
  def find_by attr:, value:
    index(attr)[value]
  end

  # Assuming uniqe index
  def find_or_create_by attr:, value:
    index(attr)[value] ||= @obj_class.new(**{attr.to_sym => value})
  end

  private

  def index attr
    @idxs[attr] ||= create_index(attr)
  end

  def create_index attr
    @objs.to_h do |obj|
      [obj.send(attr.to_sym), obj]
    end
  end

  def reindex!
    @idxs.keys.each do |idx_attr|
      @idxs[idx_attr] = create_index idx_attr
    end
  end
end
