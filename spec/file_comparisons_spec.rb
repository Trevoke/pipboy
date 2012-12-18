require 'spec_helper'

module Pipboy
  describe "Comparing Files" do
    include FileComparisons
    let(:output) { StringIO.new }

    it 'gives a message if the file does not exist' do
      existence_of_file = file_exists? 'filename_not_existant', output
      existence_of_file.should be_false
      output.string.should eq "filename_not_existant does not exist.\n"
    end

  end
end
