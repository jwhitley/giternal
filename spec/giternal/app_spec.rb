require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

module Giternal
  describe App do
    before(:each) do
      @app = App.new("some_fake_dir")
      @mock_config = stub("config").as_null_object
    end

    describe "should support action introspection" do
      before(:each) do
        App::Actions.send(:define_method, :test_method) { nil }
      end

      after(:each) do
        App::Actions.send(:remove_method, :test_method)
      end

      it "should know its actions" do
        App.actions.should include(:test_method)
      end

      it "should know its action names" do
        App.action_names.should include("test_method")
      end

      it "should run valid commands" do
        @app.should_receive(:test_method)
        @app.run 'test_method'
      end

      it "should not run unknown commands" do
        @app.should_not_receive(:wombat)
        expect { @app.run 'wombat' }.to raise_error(Giternal::Error::UnknownCommand)
      end

      it "should not run invalid commands" do
        @app.should_not_receive(:config)
        expect { @app.run 'config' }.to raise_error(Giternal::Error::UnknownCommand)
      end
    end

    describe "loading the config file" do
      before(:each) do
        File.stub!(:file?).and_return true
        File.stub!(:read).and_return "yaml config"
        YamlConfig.stub!(:new).and_return @mock_config
      end

      it "should look for config/giternal.yml" do
        File.should_receive(:file?).with(/some_fake_dir\/config\/giternal\.yml/)
        @app.config
      end

      it "should look for .giternal.yml if giternal.yml does not exist" do
        File.should_receive(:file?).with(/some_fake_dir\/config\/giternal\.yml/).and_return false
        File.should_receive(:file?).with(/some_fake_dir\/\.giternal\.yml/).and_return true
        @app.config
      end

      it "should exit with an error when no config file exists" do
        File.stub!(:file?).and_return false
        $stderr.should_receive(:puts)
        @app.should_receive(:exit).with(1)
        @app.config
      end

      it "should create a config from the config file" do
        YamlConfig.should_receive(:new).with('some_fake_dir', "yaml config").and_return @mock_config
        @app.config
      end
    end

    describe "app actions" do
      before(:each) do
        @app.stub!(:config).and_return @mock_config
        @mock_repo = mock("repo")
        @mock_config.stub!(:each_repo).and_yield(@mock_repo)
      end

      it "should update each of the repositories" do
        @mock_repo.should_receive(:update)
        @app.update
      end
    end
  end
end
