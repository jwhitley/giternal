require 'giternal'

require 'fileutils'

module Giternal
  class Repository
    class << self
      attr_accessor :verbose
    end
    attr_accessor :verbose

    def initialize(base_dir, name, repo_url, rel_path, branch=nil)
      @base_dir = base_dir
      @name = name
      @repo_url = repo_url
      @rel_path = rel_path
      if branch != nil
        @branch = branch
      else
        @branch = "master"
      end
      @verbose = self.class.verbose
    end

    def update
      git_ignore_self

      return true if frozen?
      FileUtils.mkdir_p checkout_path unless File.exist?(checkout_path)
      if checked_out?
        if !File.exist?(repo_path + '/.git')
          raise "Directory '#{@name}' exists but is not a git repository"
        else
          current_branch = (`cd #{repo_path} && git branch`).split[1]
          if current_branch != @branch
            `cd #{repo_path} && git checkout #{@branch}`
          end
          update_output { `cd #{repo_path} && git pull 2>&1` }
        end
      else
        update_output { `cd #{checkout_path} && git clone #{@repo_url} #{@name} -b #{@branch}` }
      end
      true
    end

    def checked_out?
      File.exist?(repo_path)
    end

    private
    def checkout_path
      File.expand_path(File.join(@base_dir, @rel_path))
    end

    def repo_path
      File.expand_path(checkout_path + '/' + @name)
    end

    def rel_repo_path
      @rel_path + '/' + @name
    end

    def update_output(&block)
      puts "Updating #{@name}" if verbose
      block.call
      puts " ..updated\n" if verbose
    end

    def git_ignore_self
      Dir.chdir(@base_dir) do
        contents = File.read('.gitignore') if File.exist?('.gitignore')

        unless contents.to_s.include?(rel_repo_path)
          File.open('.gitignore', 'w') do |file|
            if contents
              file << contents
              file << "\n" unless contents[-1] == 10 # ascii code for \n
            end
            file << rel_repo_path << "\n"
          end
        end
      end
    end
  end
end
