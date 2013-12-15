# encoding: utf-8

module Kernel

  private

  def Sparsify(hsh, options = {})
    Sparsify.sparse(hsh, options)
  end

  def Unsparsify(hsh, options = {})
    Sparsify.unsparse(hsh, options)
  end
end
