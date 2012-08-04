require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

module Giternal
  describe Repository do
    # The "core_workflow" examples are shared between the default branch (i.e.
    # master) suite and the explicit branch suite.
    shared_examples "core_workflow" do
      it "should check itself out to a dir" do
        @repository.update
        File.file?(GiternalHelper.checked_out_path('foo/foo')).should be_true
        File.read(GiternalHelper.checked_out_path('foo/foo')).strip.
          should == 'foo'
      end

      it "should be ignored from git (in subdir)" do
        @repository.update
        Dir.chdir(GiternalHelper.base_project_dir) do
          # TODO: What I really want is to say it shouldn't include 'foo'
          `git status`.should_not include('dependencies')
          File.read('.gitignore').should == "/dependencies/foo\n"
        end
      end

      it "should be ignored from git (in root dir)" do
        GiternalHelper.create_repo 'bar'
        repo = Repository.new(GiternalHelper.base_project_dir, "bar",
                              GiternalHelper.external_path('bar'),
                              nil)
        repo.update
        Dir.chdir(GiternalHelper.base_project_dir) do
          # TODO: What I really want is to say it shouldn't include 'foo'
          `git status --porcelain`.should_not include('bar')
          File.read('.gitignore').should == "/bar\n"
        end
      end

      it "should only add itself to .gitignore if it's not already there" do
        Dir.chdir(GiternalHelper.base_project_dir) do
          File.open('.gitignore', 'w') {|f| f << "/dependencies/foo\n" }
        end

        @repository.update

        Dir.chdir(GiternalHelper.base_project_dir) do
          File.read('.gitignore').should == "/dependencies/foo\n"
        end
      end

      it "adds a newline if it needs to" do
        Dir.chdir(GiternalHelper.base_project_dir) do
          File.open('.gitignore', 'w') {|f| f << "/something/else" }
        end

        @repository.update

        Dir.chdir(GiternalHelper.base_project_dir) do
          File.read('.gitignore').should == "/something/else\n/dependencies/foo\n"
        end
      end

      it "should not add extraneous newlines" do
        Dir.chdir(GiternalHelper.base_project_dir) do
          File.open('.gitignore', 'w') {|f| f << "/something/else\n" }
        end
        
        @repository.update

        Dir.chdir(GiternalHelper.base_project_dir) do
          contents = File.read('.gitignore')
          contents.should == "/something/else\n/dependencies/foo\n"
        end
      end

      it "should not show any output when verbose mode is off" do
        @repository.verbose = false
        @repository.should_not_receive(:puts)
        @repository.update
      end

      it "should not show output when verbose mode is on" do
        @repository.verbose = true
        @repository.should_receive(:puts).any_number_of_times
        @repository.update
      end

      it "should update the repo when it's already been checked out" do
        @repository.update
        GiternalHelper.add_content 'foo', 'newfile'
        @repository.update
        File.file?(GiternalHelper.checked_out_path('foo/newfile')).should be_true
        File.read(GiternalHelper.checked_out_path('foo/newfile')).strip.
          should == 'newfile'
      end

      it "should raise an error if the directory does not exist" do
        FileUtils.mkdir_p(GiternalHelper.checked_out_path(''))
        lambda {
          @repository.git
        }.should raise_error(Giternal::Error::NotCheckedOut)
      end

      it "should raise an error if the directory exists but there's no .git dir" do
        FileUtils.mkdir_p(GiternalHelper.checked_out_path('foo'))
        lambda {
          @repository.update
        }.should raise_error(Giternal::Error::NotGitRepo)
      end

      it "should switch to a new upstream branch" do
        @repository.update

        GiternalHelper.create_branch 'foo', 'second_branch'
        GiternalHelper.add_content 'foo', 'branchfile'
        @repository = Repository.new(GiternalHelper.base_project_dir, "foo",
                                     GiternalHelper.external_path('foo'),
                                     'dependencies', 'second_branch')
        @repository.update

        Dir.chdir(GiternalHelper.checked_out_path('foo')) do
          `git symbolic-ref -q HEAD | sed -e 's|^refs/heads/||'`.strip.should == 'second_branch'
        end
        File.file?(GiternalHelper.checked_out_path('foo/branchfile')).should be_true
        File.read(GiternalHelper.checked_out_path('foo/branchfile')).strip.
          should == 'branchfile'
      end
    end

    context "with default branch" do
      before(:each) do
        GiternalHelper.create_main_repo
        GiternalHelper.create_repo 'foo'
        @repository = Repository.new(GiternalHelper.base_project_dir, "foo",
                                     GiternalHelper.external_path('foo'),
                                     'dependencies')
      end

      include_examples "core_workflow"
    end

    context "with explicit branch" do
      before(:each) do
        GiternalHelper.create_main_repo
        GiternalHelper.create_repo 'foo'
        GiternalHelper.create_branch 'foo', 'test_branch'
        @repository = Repository.new(GiternalHelper.base_project_dir, "foo",
                                     GiternalHelper.external_path('foo'),
                                     'dependencies', 'test_branch')
      end
      
      include_examples "core_workflow"

      it "should check out the specified branch" do
        @repository.update
        Dir.chdir(GiternalHelper.checked_out_path('foo')) do
          `git symbolic-ref -q HEAD | sed -e 's|^refs/heads/||'`.strip.should == 'test_branch'
        end
      end

    end
  end
end
