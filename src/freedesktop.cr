# Provide XDG base directories on a POSIX or POSIX-like system
module Freedesktop
  VERSION     = {{ `shards version {{__DIR__}}`.chomp.stringify }}
  VALUE_CACHE = {} of String => Path
  LIST_CACHE  = {} of String => Array(Path)

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
    Dir.mkdir_p path, mode: 0o700 unless File.directory? path
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

  def xdg_data_home
    cached_value "XDG_DATA_HOME", "~/.local/share"
  end

  def xdg_config_home
    cached_value "XDG_CONFIG_HOME", "~/.config"
  end

  def xdg_state_home
    cached_value "XDG_STATE_HOME", "~/.local/state"
  end

  def xdg_data_dirs
    cached_list "XDG_DATA_DIRS", "/usr/local/share/:/usr/share/"
  end

  def xdg_config_dirs
    cached_list "XDG_CONFIG_DIRS", "/etc/xdg"
  end

  def xdg_runtime_dir
    dir = cached_value "XDG_RUNTIME_DIR", "#{Dir.tempdir}/.xdg_runtime_dir"
    unless File.directory? dir
      Dir.mkdir_p dir, mode: 0o700
      File.chmod(dir, 0o700)
    end
    dir
  end
end
