# encoding: utf-8

module Sparsify
  module HelperMethods
    def Sparsify(hsh, options = {})
      Sparsify.sparse(hsh, options)
    end

    def Unsparsify(hsh, options = {})
      Sparsify.unsparse(hsh, options)
    end
  end

  extend HelperMethods
end

include Sparsify::HelperMethods
