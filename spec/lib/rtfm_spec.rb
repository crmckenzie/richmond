require_relative '../spec_helper'

describe Richmond::RTFM do

  let!(:dir) do
    file = File.expand_path('../../', __FILE__)
    File.dirname file
  end

  subject { Richmond::RTFM.new }
  
  describe '.parse_output_file' do

    it 'pulls the output-file out of the start line' do
      line = '=begin richmond output-file: output/testfile.output'
      expect(subject.parse_output_file line).to eq 'output/testfile.output'
    end

  end

  describe '.rtfm' do

    let! (:result) { subject.scan dir }

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
          expect(lines.first).to eq "this:\n"
          expect(lines.last).to eq "  - array item 2\n" 
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

=begin richmond output-file: output/file1.txt
  some more file 1 comments
=end

=begin richmond
  this line should appear in the output/file1.txt
=end

      it "should have keys for file1.txt and file2.txt" do
        expect(result.output).to have_key('output/file1.txt')
        expect(result.output).to have_key('output/file2.txt')
      end

      it 'should have 1 line for file 2' do
        expect(result.output['output/file2.txt']).to include "  file 2 comments\n"
      end

      it 'should merge file 1 lines from all relevant comment blocks' do
        expect(result.output['output/file1.txt']).to include("  file 1 comments\n")
        expect(result.output['output/file1.txt']).to include("  some more file 1 comments\n")
        expect(result.output['output/file1.txt']).to include("  this line should appear in the output/file1.txt\n")
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

    let! (:input_result) { subject.scan dir }

    before(:each) do
      input_result.output.each_pair do |file, lines|
        File.delete file if File.exists? file
      end
    end

    let!(:emit_result) { subject.emit input_result.output }

    describe 'files created' do

      it 'emit_result is not nil' do
        expect(emit_result).to_not be nil
      end

      it 'creates the output files' do
        input_result.output.keys.each do |file|
          expect(File.exists? file).to eq(true), file
        end
      end

    end

  end

end
