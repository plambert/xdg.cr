# xdg

Simple implementation of the [freedesktop.org](https://freedesktop.org) [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir/latest/)

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     xdg:
       github: plambert/xdg.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "xdg"

XDG.xdg_config_home # => Path["/home/user/.config"]
XDG.xdg_data_dirs   # => [Path["/usr/local/share/"], Path["/usr/share/"]]
```

The module is also available under the `Freedesktop` name for callers who
prefer to name it after the specification:

```crystal
Freedesktop.xdg_config_home # => Path["/home/user/.config"]
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/plambert/xdg.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Paul M. Lambert](https://github.com/plambert) - creator and maintainer
