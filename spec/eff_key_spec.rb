require 'spec_helper'
require 'git'

module Pipboy
  describe EffKey do
    let(:configdir) { Dir.mktmpdir }
    let(:file) { Tempfile.new 'filename', configdir }
    let(:eff_key) { EffKey.new configdir }

    after(:each) do
      FileUtils.rmtree configdir
    end

    context "with existing Git repo" do

      before(:each) do
        Git.init configdir
      end

      it 'adds and commits a file' do
        eff_key.save file
        g = Git.open configdir
        g.status.untracked.should be_empty 
      end
    end

    context "without git repo" do

      it "adds and commits a file"do
        expect do
          eff_key.save file
        end.to_not raise_error(ArgumentError, "path does not exist")
      end
    end

    it "restores a file from the committed setup"
  end
end
