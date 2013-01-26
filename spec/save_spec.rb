require 'spec_helper'

module Pipboy
  describe Save do

    let(:configdir) { Dir.mktmpdir }
    let(:homedir) { Dir.mktmpdir }
    let(:db_file) { Tempfile.new 'db_file' }
    let(:monitor) { Monitor.new(configdir: configdir) }

    after do
      [configdir, homedir].each { |x| FileUtils.rmtree x}
      FileUtils.rm db_file
    end

    subject { Save.new db: db_file }

    it 'saves a watched file and its corresponding location' do
      filename = '.bashrc'
      file = Tempfile.new filename, homedir 
      subject.call({File.basename(file) => homedir})
      subject.values[File.basename(file)].should eq homedir
    end
  end

end
