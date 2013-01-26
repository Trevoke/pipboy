require 'spec_helper'
require 'yaml'

module Pipboy
  describe Inventory do
    let(:yml_file) { File.join App.root, 'spec', 'fixtures', 'saved_files.yml' }
    subject{ Inventory.new db: yml_file }

    it 'gives you a list of files and their locations' do
      output = subject.list.join("\n")
      output.should include '.bashrc'
      output.should include 'Xorg.log.0'
      output.should include '/tmp'
    end

    it 'tells you if a particular file is backed up' do
      subject.retrieve('.bashrc').should eq '~'
    end

    it 'stores a file and its location' do
      subject.store '/home/user/.zshrc'
      subject.retrieve(".zshrc").should eq "/home/user"
    end

    it 'creates the storage destination if it does not exist' do
      Dir.mktmpdir do |dir|
        expect do
        Inventory.new(db: "#{dir}/somefile.yml").
            store("/some/path")
        end.to_not raise_error Errno::ENOENT
      end
    end

    it "raises an error if asked to store a file already stored"
  end
end
