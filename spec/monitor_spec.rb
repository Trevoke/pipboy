require 'spec_helper'

module Pipboy
  describe Monitor do
    let(:configdir) { Dir.mktmpdir }
    let(:homedir) { Dir.mktmpdir }

    after do
      [configdir, homedir].each { |x| FileUtils.rmtree x}
    end
    subject { Monitor.new configdir: configdir }

    context "watching" do
      context "a file" do
        let(:filename) { '.bashrc' }

        context "that exists" do
          let(:file) { Tempfile.new filename, homedir }
          before { subject.watch file }

          its(:files) { should eq %W[. .. #{File.basename(file)}] }

          it "becomes a symlink" do
            File.symlink?(file).should be_true
          end
        end

        context "that does not exist" do
          let(:file) { filename }

          it "raises an error" do
            expect do
              subject.watch file
            end.to raise_error FileDoesNotExist
          end

          its(:files) { should eq %w[. ..] }

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
  end
end
