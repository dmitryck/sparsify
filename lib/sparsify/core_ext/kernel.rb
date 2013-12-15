# encoding: utf-8

module Kernel

  private

  # @see Sparsify#sparse
  # @api public
  def Sparsify(hsh, options = {})
    Sparsify.sparse(hsh, options)
  end

  # @see Sparsify#unsparse
  # @api public
  def Unsparsify(hsh, options = {})
    Sparsify.unsparse(hsh, options)
  end
end
