require 'spec_helper'
require 'yaml'
require 'stringio'

module Pipboy
  describe Inventory do
    let(:yml_file) { File.join App.root, 'spec', 'fixtures', 'saved_files.yml' }
    let(:output) { StringIO.new }  

    it 'gives you a list of files and their locations' do
      subject.list(yml_file, output)
      output.string.should include '.bashrc'
      output.string.should include 'Xorg.log.0'
      output.string.should include '/tmp'
    end

    it 'tells you if a particular file is backed up' do
      p yml_file
      subject.retrieve('.bashrc', yml_file).should eq '~'
    end
  end
end
