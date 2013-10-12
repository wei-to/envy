require 'spec_helper'

describe Envy do
  
  before(:each) do
    Envy.stub(:environment) { 'development' }
    Envy.stub(:fog_file) { File.expand_path('../../fixtures/fog.yml', __FILE__) }
    Envy.stub(:vars_file) { File.expand_path('../../fixtures/envy.yml', __FILE__) }
  end
    
  describe '.vars_yaml' do    
    context 'when file exists' do
      it 'loads YAML' do
        expect(Envy.vars_yaml).to be_a(Hash)
        expect(Envy.vars_yaml).to include('development', 'production', 'KEY1')
      end
    end    
    context 'when file does not exist' do
      it 'returns an empty hash' do        
        Envy.stub(:vars_file) { File.expand_path('../../fixtures/envy.missing.yml', __FILE__) }
        expect(Envy.vars_yaml).to eq({})
      end
    end
  end
    
  describe '.global_vars' do
    it 'fetches all variables not associated to an environment' do
      expect(Envy.global_vars).to include('KEY1', 'KEY2')
      expect(Envy.global_vars).to_not include('KEY3', 'KEY4')
    end
  end

  describe '.environment_vars' do
    it 'fetches only those vars for the given environment' do
      expect(Envy.environment_vars).to include('KEY1', 'KEY3')
      expect(Envy.environment_vars).to_not include('KEY4')
    end
  end  
  
  describe '.vars' do
    it 'includes default variables and environment variables' do
      expect(Envy.vars).to include('KEY1', 'KEY2', 'KEY3')
      expect(Envy.vars).to_not include('KEY4')
    end    
    it 'prioritises environment varaibles' do
      expect(Envy.vars).to include({'KEY1' => 'key1-development'})
    end
  end
  
  describe '.load_vars' do
    it 'exposes variables in ENV' do
      Envy.load_vars
      Envy.vars.each do |key, value|
        expect(ENV).to include(key)
      end
    end    
    it 'does not overwite existing ENV values' do
      ENV['KEY1'] = 'key1-manual'
      Envy.load_vars
      expect(ENV['KEY1']).to eq('key1-manual')
    end
  end
  
  describe '.fog_credentials' do
    context 'with AWS configured' do
      context 'when file exists' do
        it 'exposes S3 credentials' do
          expect(Envy.fog_credentials).to include('fog_credentials', 'fog_directory')
        end
      end
      context 'when file does not exist' do
        it 'returns an empty hash' do        
          Envy.stub(:fog_file) { File.expand_path('../../fixtures/fog.missing.yml', __FILE__) }
          expect(Envy.fog_credentials).to eq({})
        end
      end
      context 'when file exists but is invalid' do
        it 'raises an error' do
          Envy.stub(:fog_file) { File.expand_path('../../fixtures/fog.invalid.yml', __FILE__) }
          expect{Envy.fog_credentials}.to raise_error Envy::ConfigurationError
        end
      end
    end
  end
  
  describe '.fog_root' do
    context 'with AWS configured' do
      it 'returns an AWS bucket' do
        expect(Envy.fog_root).to be_a(Fog::Storage::AWS::Directory)
      end
    end
    context 'with no AWS configuration' do
      before(:each) do
        Envy.stub(:fog_file) { File.expand_path('../../fixtures/fog.missing.yml', __FILE__) }
      end
      it 'raises a configuration error' do
        expect{Envy.fog_root}.to raise_error Envy::ConfigurationError
      end
    end
    context 'with incomplete or incorrect fog configuration' do
      before(:each) do
        Envy.stub(:fog_file) { File.expand_path('../../fixtures/fog.incomplete.yml', __FILE__) }
      end
      it 'raises an argument error' do
        expect{Envy.fog_root}.to raise_error Envy::ConfigurationError
      end
    end    
  end
  
  describe '.upload_vars' do
    before(:each) do
      @fog_file = Envy.upload_vars
    end
    it 'uploads the variables' do      
      expect(@fog_file.body).to eq(File.read(Envy.vars_file))
    end
    it 'protects the upload' do
      expect(@fog_file.public_url).to be_nil
    end
  end
  
  describe '.download_vars' do
    before(:each) do
      Envy.stub(:vars_file) { File.expand_path('../../fixtures/envy.old.yml', __FILE__) }
      @upload1 = Envy.upload_vars
      Envy.stub(:vars_file) { File.expand_path('../../fixtures/envy.yml', __FILE__) }
      @upload2 = Envy.upload_vars      
    end
    it 'downloads the most-recent variables' do
      fog_file = Envy.download_vars
      expect(fog_file.body).to eq(@upload2.body)
    end
    it "generates envy.yml if it doesn't exist" do
      file = File.expand_path("/tmp/envy.#{Time.now.to_f}.yml", __FILE__)
      expect(File.exist?(file)).to be_false
      Envy.stub(:vars_file) { file }
      Envy.download_vars
      expect(File.exist?(file)).to be_true
    end
    it 'updates the local envy.yml' do
      file = File.expand_path('../../fixtures/envy.downloaded.yml', __FILE__)
      File.open(file, 'w') {}
      Envy.stub(:vars_file) { file }
      download = Envy.download_vars
      expect(File.read(Envy.vars_file)).to eq(download.body)
    end
  end
  
end