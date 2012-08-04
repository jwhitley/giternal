require 'giternal'

module Giternal
  class App

    def self.usage
      "Usage: giternal <command>\n"
    end
    
    def self.actions
      App::Actions.instance_methods(false)
    end

    def self.action_names
      actions.map { |m| m.to_s }
    end

    def initialize(base_dir)
      @base_dir = base_dir
    end

    def run(action, *args)
      if self.class.action_names.include?(action)
        send(action, *args)
      else
        raise Giternal::Error::UnknownCommand, action
      end
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

    module Actions
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
    end

    include Actions

  end
end
