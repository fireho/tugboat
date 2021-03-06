require 'singleton'

module Tugboat
  # This is the configuration object. It reads in configuration
  # from a .tugboat file located in the user's home directory

  class Configuration
    include Singleton
    attr_reader :data
    attr_reader :path

    FILE_NAME = '.tugboat'

    DEFAULT_SSH_KEY_PATH = '.ssh/id_rsa'
    DEFAULT_SSH_PORT     = '22'
    DEFAULT_SSH_KEY      = ''

    DEFAULT_REGION   = '1'
    DEFAULT_IMAGE    = '284203'
    DEFAULT_SIZE     = '66'

    # DEFAULT_SORT_BY  = 'name' # droplet#name, ip, region, status...

    REGION_NAMES = {
      1 => 'New York 1',
      2 => 'Amsterdam',
      3 => 'San Francisco 1',
      4 => 'New York 2'
    }

    SIZE_NAMES = {
      66 => "512MB",
      63 => "1GB",
      62 => "2GB",
      64 => "4GB",
      65 => "8GB",
      61 => "16GB",
      60 => "32GB",
      70 => "48GB",
      69 => "64GB",
      68 => "96GB"
    }

    def initialize
      @path = ENV["TUGBOAT_CONFIG_PATH"] || File.join(File.expand_path("~"), FILE_NAME)
      @data = self.load_config_file
    end

    # If we can't load the config file, self.data is nil, which we can
    # check for in CheckConfiguration
    def load_config_file
      require 'yaml'
      YAML.load_file(@path)
    rescue Errno::ENOENT
      return
    end

    def client_key
      @data['authentication']['client_key']
    end

    def api_key
      @data['authentication']['api_key']
    end

    def ssh_key_path
      @data['ssh']['ssh_key_path']
    end

    def ssh_user
      @data['ssh']['ssh_user']
    end

    def ssh_port
      @data['ssh']['ssh_port']
    end

    def default_region
      @data['defaults'].nil? ? DEFAULT_REGION : @data['defaults']['region']
    end

    def default_image
      @data['defaults'].nil? ? DEFAULT_IMAGE : @data['defaults']['image']
    end

    def default_size
      @data['defaults'].nil? ? DEFAULT_SIZE : @data['defaults']['size']
    end

    def default_ssh_key
      @data['defaults'].nil? ? DEFAULT_SSH_KEY : @data['defaults']['ssh_key']
    end

    # Re-runs initialize
    def reset!
      self.send(:initialize)
    end

    # Re-loads the config
    def reload!
      @data = self.load_config_file
    end

    # Writes a config file
    def create_config_file(client, api, ssh_key_path, ssh_user, ssh_port, region, image, size, ssh_key)
      # Default SSH Key path
      if ssh_key_path.empty?
        ssh_key_path = File.join(File.expand_path("~"), DEFAULT_SSH_KEY_PATH)
      end

      if ssh_user.empty?
        ssh_user = ENV['USER']
      end

      if ssh_port.empty?
        ssh_port = DEFAULT_SSH_PORT
      end

      if region.empty?
        region = DEFAULT_REGION
      end

      if image.empty?
        image = DEFAULT_IMAGE
      end

      if size.empty?
        size = DEFAULT_SIZE
      end

      if ssh_key.empty?
        default_ssh_key = DEFAULT_SSH_KEY
      end

      require 'yaml'
      File.open(@path, File::RDWR|File::TRUNC|File::CREAT, 0600) do |file|
        data = {
                'authentication' => { 'client_key' => client, 'api_key' => api },
                'ssh' => { 'ssh_user' => ssh_user, 'ssh_key_path' => ssh_key_path , 'ssh_port' => ssh_port },
                'defaults' => { 'region' => region, 'image' => image, 'size' => size, 'ssh_key' => ssh_key }
              }
        file.write data.to_yaml
      end
    end

  end
end
