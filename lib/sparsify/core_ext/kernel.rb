# encoding: utf-8

module Kernel

  # @see Sparsify#sparse
  # @api public
  def Sparsify(hsh, options = {})
    Sparsify.sparse(hsh, options)
  end
  private :Sparsify

  # @see Sparsify#unsparse
  # @api public
  def Unsparsify(hsh, options = {})
    Sparsify.unsparse(hsh, options)
  end
  private :Unsparsify
end
