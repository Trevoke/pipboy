require 'spec_helper'

module Pipboy
  describe Monitor do
    let(:configdir) { Dir.mktmpdir }
    let(:homedir) { Dir.mktmpdir }

    before do
      Pipboy.config do |c|
        c.config_dir = configdir
      end
    end

    after do
      [configdir, homedir].each { |x| FileUtils.rmtree x }
    end

    context "watching" do
      context "a file" do
        let(:filename) { '.bashrc' }

        context "that exists" do
          let(:file) { Tempfile.new filename, homedir }
          before { subject.watch file.path }

          its(:files) { should include File.basename(file) }

          it "becomes a symlink" do
            File.symlink?(file).should be_truthy
          end

          it 'is watched' do
            subject.watched?(File.basename(file)).should be_truthy
          end
        end

        context "that does not exist" do
          let(:file) { filename }

          it "raises an error" do
            expect do
              subject.watch file
            end.to raise_error FileDoesNotExist
          end

          its(:files) { should match_array %w[. ..] }

        end
      end

      context "a directory" do
        let(:dirname) { 'config' }
        #   it 'saves a directory with a file in it'
        context "that is empty" do

          it 'is saved' do
            pending
          end
        end
        #   it 'saves everything in a directory'
        #   it 'raises an error when given a non-existent directory'
      end
    end

    context 'file status' do
      it 'reports when a file is not watched' do
        subject.watched?('some_file').should be_falsey
      end
    end

  end
end
