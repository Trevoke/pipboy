require 'spec_helper'
require 'fileutils'
require 'tempfile'

describe Pipboy do

  context "watch" do

    context "a file" do
      context "that exists" do

        it "is stored away" do
          pending
          file_name = ".filename"
          file_contents = File.read file_name

          expect do
            subject.watch file_name
          end.to change(File.symlink?(file_name)).from(false).to(true)

          subject.dir.file_listing.should include file_name
          subject.dir.read(file_name).should eq file_contents
        end
      end
      context "that does not exist" do
        it 'raises an error'
      end
    end

    context "a directory" do
      it 'saves an empty directory'
      it 'saves a directory with a file in it'
      it 'saves everything in a directory'
    end

  end

  context "list" do
    it 'lists a saved file along with the existing symlink'
    it 'lists a saved dir along with existing symlink'
    it 'lists the contents of saved directories along with existing symlinks'
  end

  context "stats" do
    it 'checks that the .pipboy directory exists'
    it 'checks that the .pipboy directory is a git repo'
  end

  context "quicksave" do
    it 'commits with a generic message and sends to a git remote named origin'
    it 'complains loudly if there is no git remote named origin'
    it 'does the same thing if you call f4 or F4 instead'
  end

  context "quickload" do
    it 'does the same thing if you call f5 or F5 instead'
    it 'essentially does a git add --all and then a git reset --hard'
  end

  context "station" do
    it 'pulls from a given git repo'
    it 'pulls from a github repo if given one argument that looks like "username/repo"'
  end
end
