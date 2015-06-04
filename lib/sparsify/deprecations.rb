# encoding: utf-8

require 'set'

module Sparsify
  module Deprecations
    class << self
      def deprecate(message, target)
        @deprecations ||= Set.new
        msg = "Sparsify: #{message} is deprecated " +
              "and will be removed in #{target} (at #{external_callpoint})"
        warn(msg) if @deprecations.add?(msg)
      end

      private

      def external_callpoint
        caller.drop_while { |loc| loc['lib/sparsify/'] }.first
      end
    end

    private

    def deprecate(message, target)
      Deprecations.deprecate(message, target)
    end
  end
end
