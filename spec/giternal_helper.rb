require 'fileutils'

class GiternalHelper
  @@giternal_base ||= File.expand_path(File.dirname(__FILE__) + '/..')

  def self.create_main_repo
    without_git_env do
      FileUtils.mkdir_p tmp_path
      Dir.chdir(tmp_path) do
        FileUtils.mkdir "main_repo"
        Dir.chdir('main_repo') do
          `git init`
          `echo 'first content' > starter_repo`
          `git add starter_repo`
          `git commit -m "starter repo"`
        end
      end
    end
  end

  def self.tmp_path
    "/tmp/giternal_test"
  end

  def self.giternal_base
    @@giternal_base
  end

  def self.base_project_dir
    tmp_path + '/main_repo'
  end

  def self.run(*args)
    `#{giternal_base}/bin/giternal #{args.join(' ')}`
  end

  def self.create_repo(repo_name, branch=nil)
    without_git_env do
      Dir.chdir(tmp_path) do
        FileUtils.mkdir_p "externals/#{repo_name}"
        `cd externals/#{repo_name} && git init`
      end
      add_content repo_name
      add_to_config_file repo_name
      create_branch repo_name, branch if branch
    end
  end

  def self.clone_bare_repo(repo_name)
    without_git_env do
      Dir.chdir(tmp_path+"/externals") do
        `git clone -q --bare #{repo_name} #{repo_name}.git`
      end
    end
  end

  def self.push_to_bare_repo(repo_name)
    without_git_env do
      self.in_repo repo_name do
        remotes = `git remote`.split("\n")
        if remotes.include? 'origin'
          `git push -q`
        else
          `git remote add origin #{GiternalHelper.external_url repo_name}`
          `git push -q -u origin HEAD:"$(git symbolic-ref -q HEAD | sed -e 's|^refs/heads/||')"`
        end
      end
    end
  end

  def self.in_repo(repo_name)
    Dir.chdir(tmp_path + "/externals/#{repo_name}") do
      yield
    end
  end

  def self.add_to_config_file(repo_name)
    config_dir = tmp_path + '/main_repo/config'
    FileUtils.mkdir(config_dir) unless File.directory?(config_dir)
    Dir.chdir(config_dir) do
      `echo #{repo_name}: >> giternal.yml`
      `echo '  repo: #{external_path(repo_name)}' >> giternal.yml`
      `echo '  path: dependencies' >> giternal.yml`
    end
  end

  def self.add_content(repo_name, content=repo_name)
    without_git_env do
      in_repo repo_name do
        `echo #{content} >> #{content}`
        `git add #{content}`
        `git commit #{content} -m "added content to #{content}"`
      end
    end
  end

  def self.create_branch(repo_name, new_branch)
    without_git_env do
      in_repo repo_name do
        `git checkout -q master -b #{new_branch}`
      end
    end
  end

  def self.checkout_branch(repo_name, new_branch)
    without_git_env do
      in_repo repo_name do
        `git checkout -q #{new_branch}`
      end
    end
  end

  def self.external_url(repo_name)
    "file://#{external_path(repo_name)}.git"
  end

  def self.external_path(repo_name)
    File.expand_path(tmp_path + "/externals/#{repo_name}")
  end

  def self.checked_out_path(repo_name)
    File.expand_path(tmp_path + "/main_repo/dependencies/#{repo_name}")
  end

  def self.clean!
    FileUtils.rm_rf tmp_path
    %w(GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE).each {|var| ENV[var] = nil }
  end

  def self.update_externals(*args)
    Dir.chdir(tmp_path + '/main_repo') do
      GiternalHelper.run('update', *args)
    end
  end

  def self.repo_contents(path)
    without_git_env do
      Dir.chdir(path) do
        contents = `git cat-file -p HEAD`
        unless contents.include?('tree') && contents.include?('author')
          raise "something is wrong with the repo, output doesn't contain expected git elements:\n\n #{contents}"
        end
        contents
      end
    end
  end

  def self.add_external_to_ignore(repo_name)
    Dir.chdir(tmp_path + '/main_repo') do
      `echo 'dependencies/#{repo_name}' >> .gitignore`
    end
  end

  def self.without_git_env
    # Without any git environment variables
    gitenv = {}
    %w(GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE).each do |var|
      gitenv[var] = ENV[var]
      ENV[var] = nil
    end
    begin
      yield
    ensure
      gitenv.keys.each { |var| ENV[var] = gitenv[var] }
    end
  end
end


