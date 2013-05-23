# Sparsify

Convert a deeply-nested hash into a shallow sparse hash. Useful for tools that
either can't handle deeply-nested hashes or that allow partial updates via
sparse hashes.

## Usage

```ruby
require 'sparsify'

Sparsify({'foo' => { 'bar' => {'baz'=>'bingo'}}})
#=> {'foo.bar.baz' => 'bingo'}

Unsparsify({'foo.bar.baz' => 'bingo'})
#=> {'foo' => { 'bar' => {'baz'=>'bingo'}}}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
