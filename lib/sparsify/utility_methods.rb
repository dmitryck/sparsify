# encoding: utf-8

module Sparsify
  # The Utility Methods provide a significant (~4x) performance increase
  # over extend-ing instance methods everywhere we need them.
  module UtilityMethods

    # Provides a way to iterate through a deeply-nested hash as if it were
    # a sparse-hash. Used internally for generating and deconstructing sparse
    # hashes.
    #
    # @overload sparse_each(hsh, options = {}, &block)
    #   Yields once per key in sparse version of itself.
    #   @param hsh [Hash<#to_s,Object>]
    #   @param options (see Sparsify::UtilityMethods#sparse)
    #   @yieldparam [(sparse_key,value)]
    #   @return [void]
    # @overload sparse_each(hsh, options = {})
    #   @param hsh [Hash<#to_s,Object>]
    #   @param options (see Sparsify::UtilityMethods#sparse)
    #   @return [Enumerator<(sparse_key,value)>]
    def sparse_each(hsh, options = {}, &block)
      return enum_for(:sparse_each, hsh, options) unless block_given?

      inherited_prefix = options.fetch(:prefix, nil)
      separator = options.fetch(:separator, DEFAULT_SEPARATOR)
      sparse_array = options.fetch(:sparse_array, false)

      hsh.each do |partial_key, value|
        key = escaped_join(inherited_prefix, partial_key.to_s, separator)
        if value.kind_of?(Hash) && !value.empty?
          sparse_each(value, options.merge(prefix: key), &block)
        elsif sparse_array && value.kind_of?(Array) && !value.empty?
          zps = (sparse_array == :zero_pad ? "%0#{value.count.to_s.size}d" : '%d')# zero-pad string
          sparse_each(value.count.times.map(&zps.method(:%)).zip(value), options.merge(prefix: key), &block)
        else
          yield key, value
        end
      end
    end

    # Returns a sparse version of the given hash
    #
    # @param hsh [Hash<#to_s,Object>]
    # @param options (see Sparsify::UtilityMethods#sparse)
    # @return [Hash<String,Object>]
    def sparse(hsh, options = {})
      enum = sparse_each(hsh, options)
      enum.each_with_object(Hash.new) do |(key, value), memo|
        memo[key] = value
      end
    end

    # Returns a deeply-nested version of the given sparse hash
    # @param hsh [Hash<#to_s,Object>]
    # @param options (see Sparsify::UtilityMethods#sparse)
    # @return [Hash<String,Object>]
    def unsparse(hsh, options = {})
      separator = options.fetch(:separator, DEFAULT_SEPARATOR)
      hsh.each_with_object({}) do |(k, v), memo|
        current = memo
        key = escaped_split(k, separator)
        up_next = partial = key.shift
        until key.size.zero?
          up_next = key.shift
          up_next = up_next.to_i if (up_next =~ /\A[0-9]+\Z/)
          current = (current[partial] ||= (up_next.kind_of?(Integer) ? [] : {}))
          case up_next
          when Integer then raise KeyError unless current.kind_of?(Array)
          else              raise KeyError unless current.kind_of?(Hash)
          end
          partial = up_next
        end
        current[up_next] = v
      end
    end

    # Fetch a sparse key from the given deeply-nested hash.
    #
    # @overload sparse_fetch(hsh, sparse_key, default, options = {})
    #   @param hsh [Hash<#to_s,Object>]
    #   @param sparse_key [#to_s]
    #   @param default [Object] returned if sparse key not found
    #   @param options (see Sparsify::UtilityMethods#sparse)
    #   @return [Object]
    # @overload sparse_fetch(hsh, sparse_key, options = {}, &block)
    #   @param hsh [Hash<#to_s,Object>]
    #   @param sparse_key [#to_s]
    #   @param options (see Sparsify::UtilityMethods#sparse)
    #   @yieldreturn is returned if key not found
    #   @return [Object]
    # @overload sparse_fetch(hsh, sparse_key, options = {})
    #   @param hsh [Hash<#to_s,Object>]
    #   @param sparse_key [#to_s]
    #   @param options (see Sparsify::UtilityMethods#sparse)
    #   @raise KeyError if key not found
    #   @return [Object]
    def sparse_fetch(hsh, sparse_key, *args, &block)
      options = ( args.last.kind_of?(Hash) ? args.pop : {})
      default = args.pop

      separator = options.fetch(:separator, DEFAULT_SEPARATOR)

      escaped_split(sparse_key, separator).reduce(hsh) do |memo, kp|
        if memo.kind_of?(Hash) and memo.has_key?(kp)
          memo.fetch(kp)
        elsif default
          return default
        elsif block_given?
          return yield
        else
          raise KeyError, sparse_key
        end
      end
    end

    # Get a sparse key from the given deeply-nested hash, or return nil
    # if key not found.
    #
    # Worth noting is that Hash#default_proc is *not* used, as the intricacies
    # of implementation would lead to all sorts of terrible surprises.
    #
    # @param hsh [Hash<#to_s,Object>]
    # @param sparse_key [#to_s]
    # @param options (see Sparsify::UtilityMethods#sparse)
    # @return [Object]
    def sparse_get(hsh, sparse_key, options = {})
      sparse_fetch(hsh, sparse_key, options) { nil }
    end

    private

    # Utility method for backslash-escaping a string
    # @param str [String]
    # @param separator [String] single-character string
    # @return [String]
    def escape(str, separator)
      pattern = /(\\|#{Regexp.escape(separator)})/
      str.gsub(pattern, '\\\\\1')
    end

    # Utility method for removing backslash-escaping from a string
    # @param str [String]
    # @param separator [String] single-character string
    # @return [String]
    def unescape(str, separator)
      pattern = /\\(\\|#{Regexp.escape(separator)})/
      str.gsub(pattern, '\1')
    end

    # Utility method for splitting a string by a separator into
    # non-escaped parts
    # @param str [String]
    # @param separator [String] single-character string
    # @return [Array<String>]
    def escaped_split(str, separator)
      unescaped_separator = /(?<!\\)(#{Regexp.escape(separator)})/
      # String#split(<Regexp>) on non zero-width matches yields the match
      # as the even entries in the array.
      parts = str.split(unescaped_separator).each_slice(2).map(&:first)
      parts.map do |part|
        unescape(part, separator)
      end
    end

    # Utility method for joining a pre-escaped string with a not-yet escaped
    # string on a given separator, escaping the new part before joining.
    # @param pre_escaped_prefix [String]
    # @param new_part [String] - will be escaped before joining
    # @param separator [String] single-character string
    # @return [String]
    def escaped_join(pre_escaped_prefix, new_part, separator)
      [pre_escaped_prefix, escape(new_part, separator)].compact.join(separator)
    end
  end

  extend UtilityMethods
end
