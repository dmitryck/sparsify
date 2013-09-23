# encoding: utf-8

require 'sparsify/version'
require 'sparsify/utility_methods'
require 'sparsify/helper_methods'
require 'sparsify/guard_methods'

# Provides sparse-key access to a Hash.
#
# {'foo'=>{'bar'=>'bingo'}}.sparse #=> {'foo.bar'=>'bingo'}
# {'foo.bar'=>'bingo'}.unsparse => {'foo'=>{'bar'=>'bingo'}}
#
module Sparsify
  # The default separator, used if not specified in command's
  # options hash.
  DEFAULT_SEPARATOR = '.'.freeze

  # Returns a sparse version of self using the options provided.
  #
  # @param options [Hash<Symbol,Object>]
  # @option options [String] :separator
  # @option options [String] :prefix
  # @return [Hash<String,Object>]
  def sparse(options = {})
    Sparsify.sparse(self, options)
  end

  # Replaces self with sparse version of itself.
  #
  # @param options (see #sparse)
  # @return [Hash<String,Object>]
  def sparse!(options = {})
    self.replace(sparse, options)
  end

  # Used internally by both Sparsify::Utility#sparse and
  # Sparsify::Utility#unsparse
  #
  # @overload sparse_eachrm (options = {}, &block)
  #   Yields once per key in sparse version of itself.
  #   @param options (see #sparse)
  #   @yieldparam [(sparse_key,value)]
  #   @return [void]
  # @overload sparse_each(options = {})
  #   @param options (see #sparse)
  #   @return [Enumerator<(sparse_key,value)>]
  def sparse_each(options = {}, &block)
    Sparsify.sparse_each(self, options, &block)
  end

  # Follows semantics of Hash#fetch
  #
  # @overload sparse_fetch(sparse_key, options = {})
  #   @param options (see #sparse)
  #   @raise [KeyError] if sparse_key not found 
  #   @return [Object]
  # @overload sparse_fetch(sparse_key, default, options = {})
  #   @param options (see #sparse)
  #   @param default [Object] the default object
  #   @return [default]
  # @overload sparse_fetch(sparse_key, options = {}, &block)
  #   @param options (see #sparse)
  #   @yield if sparse_key not founs
  #   @return [Object] that which was returned by the given block.
  def sparse_fetch(*args, &block)
    Sparsify.sparse_fetch(self, *args, &block)
  end

  # Follows semantics of Hash#[] without support for Hash#default_proc
  #
  # @overload sparse_get(sparse_key, options = {})
  #   @param options (see #sparse)
  #   @return [Object] at that address or nil if none found
  def sparse_fetch(*args, &block)
    Sparsify.sparse_fetch(self, *args, &block)
  end

  # Returns a deeply-nested hash version of self.
  #
  # @param options (see #sparse)
  # @return [Hash<String,Object>]
  def unsparse(options = {})
    Sparsify.unsparse(self, options)
  end

  # Replaces self with deeply-nested version of self.
  #
  # @param options (see #sparse)
  # @return [Hash<String,Object>]
  def unsparse!(options = {})
    self.replace(unsparse, options)
  end
end
