require_relative '../spec_helper'
describe Richmond::ScanSettings do

  describe '.new' do
    it 'expands dir to full path' do
      settings = Richmond::ScanSettings.new '.'
      expect(settings.dir).to eq File.expand_path '.' 
    end
  end

  describe 'Richmond.select filter' do
    before(:each) do
      Richmond.reset_filters
    end
    after(:each) do
      Richmond.reset_filters
    end

    it 'will grab filters from global context' do
      Richmond.select { |file|
        file.match(/scan_settings_spec/)
      }

      settings = Richmond::ScanSettings.new '.'

      expect(settings.files.size).to eq 1
      puts settings.files
      expect(settings.files).to include File.expand_path(__FILE__)
    end
  end
  
  describe 'Richmond.reject filter' do
    before(:each) do
      Richmond.reset_filters
    end
    after(:each) do
      Richmond.reset_filters
    end

    it 'will grab filters from global context' do
      Richmond.reject { |file|
        file.match(/scan_settings_spec/)
      }

      settings = Richmond::ScanSettings.new '.'
      expect(settings.files).to_not include File.expand_path(__FILE__)
    end
  end

  describe 'when a .richmond file is present' do
    before(:each) do
      Richmond.reset_filters
    end
    after(:each) do
      Richmond.reset_filters
    end

    it 'requires the richmond file' do
      file = File.expand_path File.join('.', '.richmond')
      expect(File).to receive(:exists?).with(file)
        .and_return(true)
      
      expect(Kernel).to receive(:require).with(file)
        .and_return true

      Richmond::ScanSettings.new '.'
    end

  end

end
