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

          it "symlink points to the correct location in config_dir" do
            expected_target = File.join(configdir, File.basename(file.path))
            actual_target = File.readlink(file.path)
            expect(actual_target).to eq(expected_target)
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

    context 'atomic operations' do
      it 'rolls back file move if symlink creation fails' do
        file = Tempfile.new('.testrc', homedir)
        original_content = 'test content'
        File.write(file.path, original_content)
        original_path = file.path

        # Create a regular file at the original location to prevent symlink
        # This will cause symlink creation to fail after the file is moved
        allow(File).to receive(:symlink).and_raise(Errno::EEXIST, "File exists")

        expect do
          subject.watch(original_path)
        end.to raise_error(Errno::EEXIST)

        # Verify file was rolled back to original location
        expect(File.exist?(original_path)).to be true
        expect(File.read(original_path)).to eq(original_content)
        expect(File.symlink?(original_path)).to be false
      end
    end

  end
end
