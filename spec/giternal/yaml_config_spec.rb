require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

module Giternal
  describe YamlConfig do
    it "should create repositories from the config" do
      yaml_config = <<-EOT
rspec:
  repo: git://rspec
  path: vendor/plugins
foo:
  repo: git://at/foo
  path: path/to/foo
      EOT
      config = YamlConfig.new('base_dir', yaml_config)
      Repository.should_receive(:new).with('base_dir', "rspec", "git://rspec", "vendor/plugins", nil).and_return :a_repo
      Repository.should_receive(:new).with('base_dir', "foo", "git://at/foo", "path/to/foo", nil).and_return :a_repo
      config.each_repo {|r| r.should == :a_repo}
    end

    it "should create repositories with branches from the config" do
      yaml_config = <<-EOT
rspec:
  repo: git://rspec
  path: vendor/plugins
  branch: rspec_branch
foo:
  repo: git://at/foo
  path: path/to/foo
      EOT
      config = YamlConfig.new('base_dir', yaml_config)
      Repository.should_receive(:new).with('base_dir', "rspec", "git://rspec", "vendor/plugins", 'rspec_branch').and_return :a_repo
      Repository.should_receive(:new).with('base_dir', "foo", "git://at/foo", "path/to/foo", nil).and_return :a_repo
      config.each_repo {|r| r.should == :a_repo}
    end
  end
end
