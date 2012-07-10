module Giternal
  class App
    def initialize(base_dir)
      @base_dir = base_dir
    end

    def update(*dirs)
      if dirs.empty?
        config.each_repo {|r| r.update }
      else
        dirs.each do |dir|
          if repo = config.find_repo(dir)
            repo.update
          end
        end
      end
    end

    def run(action, *args)
      send(action, *args)
    end

    def config
      return @config if @config

      config_file = ['config/giternal.yml', '.giternal.yml'].detect do |file|
        File.file? File.expand_path(@base_dir + '/' + file)
      end

      if config_file.nil?
        $stderr.puts "config/giternal.yml is missing"
        exit 1
      end

      @config = YamlConfig.new(@base_dir, File.read(config_file))
    end
  end
end
