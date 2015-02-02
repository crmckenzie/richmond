require_relative '../spec_helper'

describe Richmond::RTFM do

  let!(:dir) {
    file = File.expand_path('../../', __FILE__)
    dir = File.dirname(file)
    dir
  }

  subject {
    Richmond::RTFM.new 
  }

  describe '.rtfm' do
    let! (:result) { subject.rtfm dir }

    describe 'simple comment block' do

=begin richmond 
this:
  is: some
  yaml:
  - array item 1
  - array item 2
=end

      it 'is not nil' do
        expect(result).to_not eq nil
      end

      describe 'input' do

        it 'contains a key for the file' do
          filename = File.expand_path __FILE__
          expect(result.input).to have_key(filename)
        end

        it 'documents which comments came from which file' do
          lines = result.input[File.expand_path __FILE__]
          expect(lines.size).to eq 9 
        end
      end

      describe 'output' do
        it 'has default output filename' do
          default_filename = File.join(File.dirname(File.expand_path('../../', __FILE__)), 'output', 'richmond.output')
          expect(result.output).to have_key(default_filename) 

          lines = result.output[default_filename]
          expect(lines.first).to eq 'this:'
          expect(lines.last).to eq '  this line should appear in the default output file'
        end
      end

    end

    describe 'comment blocks with identified output files' do
=begin richmond output-file: output/file1.txt
  file 1 comments
=end

=begin richmond output-file: output/file2.txt
  file 2 comments
=end

=begin richmond
  this line should appear in the default output file
=end

=begin richmond output-file: output/file1.txt
  some more file 1 comments
=end

      it "should have keys for file1.txt and file2.txt" do
        expect(result.output).to have_key('output/file1.txt')
        expect(result.output).to have_key('output/file2.txt')
      end

      it 'should have 1 line for file 2' do
        expect(result.output['output/file2.txt']).to include '  file 2 comments'
      end

      it 'should merge file 1 lines from both comment blocks' do
        expect(result.output['output/file1.txt']).to include('  file 1 comments')
        expect(result.output['output/file1.txt']).to include('  some more file 1 comments')
      end

    end

    describe 'comment block without richmond identifier' do
=begin some random comment block
  some random comments
  should not change the test results for the richmond comment blocks
=end
    end
  end

  describe '.emit' do
    let! (:input_result) { subject.rtfm dir }

    before(:each) do
      input_result.output.each_pair do |file, lines|
        if File.exists? file
          File.delete file
        end
      end
    end

    let!(:emit_result) { subject.emit input_result.output }

    describe 'files created' do
      it 'emit_result is not nil' do
        expect(emit_result).to_not be nil
      end

      it 'creates the output files' do
        input_result.output.keys.each {|file|
          expect(File.exists? file).to eq(true), file
        }
      end

    end

  end

end
