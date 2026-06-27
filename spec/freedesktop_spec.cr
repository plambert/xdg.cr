require "./spec_helper"
require "file_utils"

# Env vars used by the module
ENV_VARS = %w[
  XDG_DATA_HOME
  XDG_CONFIG_HOME
  XDG_CACHE_HOME
  XDG_STATE_HOME
  XDG_DATA_DIRS
  XDG_CONFIG_DIRS
  XDG_RUNTIME_DIR
]

{% begin %}
  {% for modname in %w[Freedesktop XDG] %}
    describe {{ modname.id }} do
      # Save and restore env vars around each test, and clear caches
      saved_env = {} of String => String?

      before_each do
        ENV_VARS.each { |var| saved_env[var] = ENV[var]? }
        ENV_VARS.each { |var| ENV.delete(var) }
        {{ modname.id }}::VALUE_CACHE.clear
        {{ modname.id }}::LIST_CACHE.clear
      end

      after_each do
        saved_env.each do |var, val|
          if val
            ENV[var] = val
          else
            ENV.delete(var)
          end
        end
        {{ modname.id }}::VALUE_CACHE.clear
        {{ modname.id }}::LIST_CACHE.clear
      end

      describe "#xdg_data_home" do
        it "returns ~/.local/share expanded when XDG_DATA_HOME is not set" do
          tmp = File.tempname("xdg_test_home", "")
          Dir.mkdir_p(tmp)
          ENV["HOME"] = tmp
          begin
            result = {{ modname.id }}.xdg_data_home
            result.should eq(Path[tmp] / ".local" / "share")
          ensure
            ENV["HOME"] = saved_env["XDG_DATA_HOME"]? || Path.home.to_s rescue nil
            FileUtils.rm_rf(tmp)
          end
        end

        it "returns the env var path when XDG_DATA_HOME is set" do
          ENV["XDG_DATA_HOME"] = "/custom/data"
          {{ modname.id }}.xdg_data_home.should eq(Path["/custom/data"])
        end

        it "does not create the directory" do
          tmp = File.tempname("xdg_test_home", "")
          Dir.mkdir_p(tmp)
          ENV["HOME"] = tmp
          begin
            result = {{ modname.id }}.xdg_data_home
            File.directory?(result).should be_false
          ensure
            FileUtils.rm_rf(tmp)
          end
        end
      end

      describe "#xdg_config_home" do
        it "returns ~/.config expanded when XDG_CONFIG_HOME is not set" do
          tmp = File.tempname("xdg_test_home", "")
          Dir.mkdir_p(tmp)
          ENV["HOME"] = tmp
          begin
            result = {{ modname.id }}.xdg_config_home
            result.should eq(Path[tmp] / ".config")
          ensure
            FileUtils.rm_rf(tmp)
          end
        end

        it "returns the env var path when XDG_CONFIG_HOME is set" do
          ENV["XDG_CONFIG_HOME"] = "/custom/config"
          {{ modname.id }}.xdg_config_home.should eq(Path["/custom/config"])
        end
      end

      describe "#xdg_cache_home" do
        it "returns ~/.cache expanded when XDG_CACHE_HOME is not set" do
          tmp = File.tempname("xdg_test_home", "")
          Dir.mkdir_p(tmp)
          ENV["HOME"] = tmp
          begin
            result = {{ modname.id }}.xdg_cache_home
            result.should eq(Path[tmp] / ".cache")
          ensure
            FileUtils.rm_rf(tmp)
          end
        end

        it "returns the env var path when XDG_CACHE_HOME is set" do
          ENV["XDG_CACHE_HOME"] = "/custom/cache"
          {{ modname.id }}.xdg_cache_home.should eq(Path["/custom/cache"])
        end
      end

      describe "#xdg_state_home" do
        it "returns ~/.local/state expanded when XDG_STATE_HOME is not set" do
          tmp = File.tempname("xdg_test_home", "")
          Dir.mkdir_p(tmp)
          ENV["HOME"] = tmp
          begin
            result = {{ modname.id }}.xdg_state_home
            result.should eq(Path[tmp] / ".local" / "state")
          ensure
            FileUtils.rm_rf(tmp)
          end
        end

        it "returns the env var path when XDG_STATE_HOME is set" do
          ENV["XDG_STATE_HOME"] = "/custom/state"
          {{ modname.id }}.xdg_state_home.should eq(Path["/custom/state"])
        end
      end

      describe "#xdg_data_dirs" do
        it "returns [/usr/local/share, /usr/share] when XDG_DATA_DIRS is not set" do
          result = {{ modname.id }}.xdg_data_dirs
          result.should eq([Path["/usr/local/share/"], Path["/usr/share/"]])
        end

        it "returns split paths when XDG_DATA_DIRS is set" do
          ENV["XDG_DATA_DIRS"] = "/opt/share:/srv/share"
          result = {{ modname.id }}.xdg_data_dirs
          result.should eq([Path["/opt/share"], Path["/srv/share"]])
        end
      end

      describe "#xdg_config_dirs" do
        it "returns [/etc/xdg] when XDG_CONFIG_DIRS is not set" do
          result = {{ modname.id }}.xdg_config_dirs
          result.should eq([Path["/etc/xdg"]])
        end

        it "returns split paths when XDG_CONFIG_DIRS is set" do
          ENV["XDG_CONFIG_DIRS"] = "/etc/xdg/custom:/etc/xdg"
          result = {{ modname.id }}.xdg_config_dirs
          result.should eq([Path["/etc/xdg/custom"], Path["/etc/xdg"]])
        end
      end

      describe "#xdg_runtime_dir" do
        it "returns tempdir/.xdg_runtime_dir when XDG_RUNTIME_DIR is not set" do
          result = {{ modname.id }}.xdg_runtime_dir
          result.should eq(Path[Dir.tempdir] / ".xdg_runtime_dir")
        end

        it "returns the env var path when XDG_RUNTIME_DIR is set" do
          tmp = File.tempname("xdg_runtime_env", "")
          ENV["XDG_RUNTIME_DIR"] = tmp
          begin
            {{ modname.id }}.xdg_runtime_dir.should eq(Path[tmp])
          ensure
            FileUtils.rm_rf(tmp)
          end
        end

        it "does not create the directory" do
          tmp = File.tempname("xdg_runtime", "")
          ENV["XDG_RUNTIME_DIR"] = tmp
          {{ modname.id }}.xdg_runtime_dir
          File.directory?(tmp).should be_false
        end
      end

      describe "shorthand aliases" do
        it "#data_home returns the same value as #xdg_data_home" do
          ENV["XDG_DATA_HOME"] = "/alias/data"
          {{ modname.id }}.data_home.should eq({{ modname.id }}.xdg_data_home)
        end

        it "#config_home returns the same value as #xdg_config_home" do
          ENV["XDG_CONFIG_HOME"] = "/alias/config"
          {{ modname.id }}.config_home.should eq({{ modname.id }}.xdg_config_home)
        end

        it "#cache_home returns the same value as #xdg_cache_home" do
          ENV["XDG_CACHE_HOME"] = "/alias/cache"
          {{ modname.id }}.cache_home.should eq({{ modname.id }}.xdg_cache_home)
        end

        it "#state_home returns the same value as #xdg_state_home" do
          ENV["XDG_STATE_HOME"] = "/alias/state"
          {{ modname.id }}.state_home.should eq({{ modname.id }}.xdg_state_home)
        end

        it "#data_dirs returns the same value as #xdg_data_dirs" do
          ENV["XDG_DATA_DIRS"] = "/alias/share:/alias/data"
          {{ modname.id }}.data_dirs.should eq({{ modname.id }}.xdg_data_dirs)
        end

        it "#config_dirs returns the same value as #xdg_config_dirs" do
          ENV["XDG_CONFIG_DIRS"] = "/alias/xdg:/alias/etc"
          {{ modname.id }}.config_dirs.should eq({{ modname.id }}.xdg_config_dirs)
        end

        it "#runtime_dir returns the same value as #xdg_runtime_dir" do
          ENV["XDG_RUNTIME_DIR"] = "/alias/runtime"
          {{ modname.id }}.runtime_dir.should eq({{ modname.id }}.xdg_runtime_dir)
        end
      end

      describe "caching" do
        it "returns cached value on subsequent calls" do
          ENV["XDG_DATA_HOME"] = "/first/path"
          {{ modname.id }}.xdg_data_home.should eq(Path["/first/path"])

          ENV["XDG_DATA_HOME"] = "/second/path"
          {{ modname.id }}.xdg_data_home.should eq(Path["/first/path"])
        end

        it "populates VALUE_CACHE after first call" do
          {{ modname.id }}::VALUE_CACHE.has_key?("XDG_DATA_HOME").should be_false
          ENV["XDG_DATA_HOME"] = "/some/path"
          {{ modname.id }}.xdg_data_home
          {{ modname.id }}::VALUE_CACHE.has_key?("XDG_DATA_HOME").should be_true
        end

        it "populates LIST_CACHE after first call" do
          {{ modname.id }}::LIST_CACHE.has_key?("XDG_DATA_DIRS").should be_false
          {{ modname.id }}.xdg_data_dirs
          {{ modname.id }}::LIST_CACHE.has_key?("XDG_DATA_DIRS").should be_true
        end
      end
    end
  {% end %}
{% end %}
