require 'giternal'
require 'fileutils'
require 'pathname'

require 'git'

module Giternal
  class Repository
    class << self
      attr_accessor :verbose
    end
    attr_accessor :verbose

    attr_reader :checkout_path

    def initialize(base_dir, name, repo_url, rel_path, branch=nil)
      @base_dir = Pathname.new(base_dir).expand_path
      @name = name
      @repo_url = repo_url
      @rel_path = rel_path || ''

      if branch != nil
        @branch = branch
      else
        @branch = "master"
      end

      @checkout_path = (@base_dir + @rel_path).expand_path
      @repo_path = @checkout_path + @name
      @verbose = self.class.verbose
    end

    def git
      begin
        @git ||= Git.open(@repo_path, :log => Giternal.logger)
      rescue ArgumentError => e
        dir = e.backtrace.first
        if dir =~ /\.git$/
          raise Giternal::Error::NotGitRepo, dir
        else
          raise Giternal::Error::NotCheckedOut, dir
        end
      end
    end

    def update
      git_ignore_self

      @checkout_path.mkpath unless @checkout_path.directory?

      if checked_out?
        update_output do
          git.remote.fetch
          if git.branch.name != @branch
            git.lib.checkout(@branch)
          end
          git.remote.merge(@branch)
        end
      else
        update_output do
          @git = Git.clone(@repo_url, @name, :path => @checkout_path.to_s)
          unless @branch == "master"
            @git.lib.checkout("origin/#{@branch}", :new_branch => @branch)
          end
        end
      end
      true
    end

    def checked_out?
      !!(@repo_path.directory? && git)
    end

    private

    def update_output(&block)
      puts "Updating #{@name}" if verbose
      block.call
      puts " ..updated\n" if verbose
    end

    def git_ignore_self
      if @rel_path.empty?
        ignore_path = "/#{@name}"
      else
        ignore_path = "/#{@rel_path}/#{@name}"
      end

      Dir.chdir(@base_dir) do
        contents = File.read('.gitignore') if File.exist?('.gitignore')

        unless contents.to_s.include?(ignore_path)
          File.open('.gitignore', 'w') do |file|
            if contents
              file << contents
              file << "\n" unless contents[-1] == "\n"
            end
            file << ignore_path << "\n"
          end
        end
      end
    end
  end
end
