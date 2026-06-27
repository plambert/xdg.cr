# Implements the XDG Base Directory Specification for resolving
# user-specific and system-wide base directories on POSIX systems.
#
# See: https://specifications.freedesktop.org/basedir/latest/
#
# All methods return `Path` values and cache their results for the
# lifetime of the process. Directories are **not** created by this
# module; that is the caller's responsibility at write time, per the spec.
#
# ```
# Freedesktop.xdg_config_home # => Path["/home/user/.config"]
# Freedesktop.xdg_data_dirs   # => [Path["/usr/local/share/"], Path["/usr/share/"]]
# ```
module Freedesktop
  {% begin %}
  VERSION = {{ `shards version`.chomp.stringify }}
  {% end %}

  # Cache for single-path lookups (the `_home` and `_dir` methods).
  # Keyed by environment variable name. Clear this to force re-reading
  # from the environment on next access.
  VALUE_CACHE = {} of String => Path

  # Cache for multi-path lookups (the `_dirs` methods).
  # Keyed by environment variable name. Clear this to force re-reading
  # from the environment on next access.
  LIST_CACHE = {} of String => Array(Path)

  extend self

  private def cached_value(env_var, default)
    if cached_value = VALUE_CACHE[env_var]?
      return cached_value
    end

    if env_value = ENV[env_var]?
      VALUE_CACHE[env_var] = Path[env_value]
      return VALUE_CACHE[env_var]
    end

    path = Path[default].expand(home: true)
    VALUE_CACHE[env_var] = path
    path
  end

  private def cached_list(env_var, default)
    if cached_value = LIST_CACHE[env_var]?
      return cached_value
    end

    if env_value = ENV[env_var]?
      LIST_CACHE[env_var] = env_value.split(':').map { |path| Path[path].expand }
      return LIST_CACHE[env_var]
    end

    paths = default.split(':').map { |path| Path[path].expand }
    LIST_CACHE[env_var] = paths
    paths
  end

  # Returns the base directory for user-specific data files.
  # Uses `$XDG_DATA_HOME`, defaulting to `~/.local/share`.
  def xdg_data_home
    cached_value "XDG_DATA_HOME", "~/.local/share"
  end

  # :ditto:
  def data_home
    xdg_data_home
  end

  # Returns the base directory for user-specific configuration files.
  # Uses `$XDG_CONFIG_HOME`, defaulting to `~/.config`.
  def xdg_config_home
    cached_value "XDG_CONFIG_HOME", "~/.config"
  end

  # :ditto:
  def config_home
    xdg_config_home
  end

  # Returns the base directory for user-specific non-essential cached data.
  # Uses `$XDG_CACHE_HOME`, defaulting to `~/.cache`.
  def xdg_cache_home
    cached_value "XDG_CACHE_HOME", "~/.cache"
  end

  # :ditto:
  def cache_home
    xdg_cache_home
  end

  # Returns the base directory for user-specific state data.
  # Uses `$XDG_STATE_HOME`, defaulting to `~/.local/state`.
  def xdg_state_home
    cached_value "XDG_STATE_HOME", "~/.local/state"
  end

  # :ditto:
  def state_home
    xdg_state_home
  end

  # Returns the preference-ordered set of additional directories to
  # search for data files. Uses `$XDG_DATA_DIRS`, defaulting to
  # `/usr/local/share/:/usr/share/`.
  def xdg_data_dirs
    cached_list "XDG_DATA_DIRS", "/usr/local/share/:/usr/share/"
  end

  # :ditto:
  def data_dirs
    xdg_data_dirs
  end

  # Returns the preference-ordered set of additional directories to
  # search for configuration files. Uses `$XDG_CONFIG_DIRS`, defaulting
  # to `/etc/xdg`.
  def xdg_config_dirs
    cached_list "XDG_CONFIG_DIRS", "/etc/xdg"
  end

  # :ditto:
  def config_dirs
    xdg_config_dirs
  end

  # Returns the base directory for user-specific runtime files (sockets,
  # named pipes, etc.). Uses `$XDG_RUNTIME_DIR`, defaulting to
  # `Dir.tempdir/.xdg_runtime_dir`.
  def xdg_runtime_dir
    cached_value "XDG_RUNTIME_DIR", "#{Dir.tempdir}/.xdg_runtime_dir"
  end

  # :ditto:
  def runtime_dir
    xdg_runtime_dir
  end
end
