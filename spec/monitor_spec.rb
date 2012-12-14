require 'spec_helper'

module Pipboy
  describe Monitor do
    context "watch" do
      context "a file" do
        after do
          FileUtils.rm_f '.bashrc' 
          FileUtils.rm_f 'tmp/.bashrc'
        end
        it "exists" do
          file = '.bashrc'
          FileUtils.touch file
          Monitor.watch file
          Monitor.files.should eq %w[. .. .bashrc]
          File.symlink?('.bashrc').should be_true
        end
        it "does not exist" do
          file = '.bashrc'
          expect do
            Monitor.watch file
          end.to raise_error FileDoesNotExist
          Monitor.files.should eq %w[. ..]
        end
      end

      context "a directory" do
        it 'saves an empty directory'
        it 'saves a directory with a file in it'
        it 'saves everything in a directory'
      end

    end
  end
end
