require "./xdg"

# `Freedesktop` is an alias for `XDG`, provided for callers who prefer
# to name the module after the freedesktop.org specification.
#
# See `XDG` for the documented API.
module Freedesktop
  include XDG
  extend self
end
