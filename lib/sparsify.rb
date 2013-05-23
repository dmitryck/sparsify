# encoding: utf-8
require 'sparsify/version'

# Extend into a hash to provide sparse and unsparse methods.
#
# {'foo'=>{'bar'=>'bingo'}}.sparse #=> {'foo.bar'=>'bingo'}
# {'foo.bar'=>'bingo'}.unsparse => {'foo'=>{'bar'=>'bingo'}}
#
module Sparsify
  DEFAULT_SEPARATOR = '.'.freeze

  module HelperMethods
    def Sparsify(hsh, options = {})
      hsh.dup.extend(Sparsify).sparse(options)
    end

    def Unsparsify(hsh, options = {})
      hsh.dup.extend(Sparsify).unsparse(options)
    end
  end
  extend HelperMethods

  def sparse(options = {})
    inherited_prefix = options.fetch(:prefix, nil)
    separator = options.fetch(:separator, DEFAULT_SEPARATOR)

    self.each_with_object(Hash.new) do |(partial_key, value), memo|
      key = ([inherited_prefix, partial_key.to_s].compact.join(separator))
      if value.kind_of? Hash
        memo.update Sparsify(value, options.merge(prefix: key))
      else
        memo[key] = value
      end
    end
  end

  def sparse!
    self.replace(sparse)
  end

  def unsparse(options = {})
    separator = options.fetch(:separator, DEFAULT_SEPARATOR)
    sparse.each_with_object(Hash.new) do |(k, v), memo|
      current = memo
      key = k.to_s.split(separator)
      current = (current[key.shift] ||= Hash.new) until key.size <= 1
      current[key.first] = v
    end
  end

  def unsparse!
    self.replace(unsparse)
  end

  def self.extended(base)
    raise ArgumentError, "<#{base.inspect}> not a Hash!" unless base.is_a? Hash
    base
  end
end

include Sparsify::HelperMethods
