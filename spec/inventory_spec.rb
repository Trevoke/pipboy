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
      subject.retrieve('~/.bashrc').should eq '/root'
    end

    it 'stores a file and its location' do
      subject.store '/home/user/.zshrc'
      subject.retrieve("/home/user/.zshrc").should eq "/home/user"
    end

    it 'creates the storage destination if it does not exist' do
      Dir.mktmpdir do |dir|
        expect do
        Inventory.new(db: "#{dir}/somefile.yml").
            store("/some/path")
        end.to_not raise_error Errno::ENOENT
        yaml = YAML.load_file File.join(dir, 'somefile.yml')
        yaml['/some/path']['dirname'].should eq '/some'
      end
    end

    it "raises an error if asked to store a file already stored"

    it "uses safe YAML loading to prevent code execution vulnerabilities" do
      Dir.mktmpdir do |dir|
        db_file = "#{dir}/test.yml"

        # Create a malicious YAML file with a Ruby object
        File.write(db_file, "--- !ruby/object:OpenStruct\ntable:\n  :command: \"rm -rf /\"\n")

        # This should raise an error with safe_load, or at minimum not execute code
        expect do
          inventory = Inventory.new(db: db_file)
          inventory.files  # Trigger the YAML load
        end.to raise_error(Psych::DisallowedClass)
      end
    end

    it "handles files with the same basename from different directories" do
      Dir.mktmpdir do |dir|
        inventory = Inventory.new(db: "#{dir}/test.yml")

        # Store two files with same basename from different directories
        inventory.store '/home/user/.bashrc'
        inventory.store '/home/admin/.bashrc'

        # Both should be retrievable
        expect(inventory.retrieve('/home/user/.bashrc')).to eq('/home/user')
        expect(inventory.retrieve('/home/admin/.bashrc')).to eq('/home/admin')

        # Inventory should have 2 entries
        expect(inventory.files.size).to eq(2)
      end
    end

    it "handles concurrent writes without data corruption" do
      Dir.mktmpdir do |dir|
        db_path = "#{dir}/test.yml"
        threads = []
        file_count = 10

        # Spawn multiple threads to write concurrently
        file_count.times do |i|
          threads << Thread.new do
            inventory = Inventory.new(db: db_path)
            inventory.store "/tmp/file#{i}.txt"
          end
        end

        # Wait for all threads to complete
        threads.each(&:join)

        # Verify all files were stored correctly
        inventory = Inventory.new(db: db_path)
        expect(inventory.files.size).to eq(file_count)

        # Verify each file is retrievable
        file_count.times do |i|
          expect(inventory.retrieve("/tmp/file#{i}.txt")).to eq('/tmp')
        end
      end
    end
  end
end
