require 'spec_helper'

describe Pipboy do

  subject { Pipboy }

  describe 'configuration' do
    subject { Pipboy.configuration }

    describe "config directory" do
      let!(:configdir) { Dir.mktmpdir }
      before { Dir.rmdir configdir }
      context "explicitly set" do
        before do
          Pipboy.config do |c|
            c.config_dir = configdir
          end
        end
        after { Dir.rmdir configdir }

        its(:config_dir) { should eq configdir }

        it "creates the config directory" do
          File.exist?(configdir).should be_truthy
        end

        it "trickles down the configuration" do
          Pipboy::Monitor.new.config_dir.should eq configdir
        end
      end

      context "implicitly set" do
        it "sets the default config path to ~/config" do
          pending "Until I properly implement fake files creation in cabinet"
          File.expand_path(subject.config_dir).should eq File.expand_path("~/config")
        end
      end

    end
  end
end

#  context "list" do
#    it 'lists a saved file along with the existing symlink'
#    it 'lists a saved dir along with existing symlink'
#    it 'lists the contents of saved directories along with existing symlinks'
#  end
#
#  context "stats" do
#    it 'checks that the .pipboy directory exists'
#    it 'checks that the .pipboy directory is a git repo'
#  end
#
#  context "quicksave" do
#    it 'commits with a generic message and sends to a git remote named origin'
#    it 'complains loudly if there is no git remote named origin'
#    it 'does the same thing if you call f4 or F4 instead'
#  end
#
#  context "quickload" do
#    it 'does the same thing if you call f5 or F5 instead'
#    it 'essentially does a git add --all and then a git reset --hard'
#  end
#
#  context "station" do
#    it 'pulls from a given git repo'
#    it 'pulls from a github repo if given one argument that looks like "username/repo"'
#  end
