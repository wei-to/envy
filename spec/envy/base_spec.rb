require 'spec_helper'

describe Envy do
  
  before(:each) do
    Envy.stub(:environment) { 'development' }
    Envy.stub(:file) { File.expand_path('../../fixtures/envy.yml', __FILE__) }
  end
    
  describe '.yaml' do    
    context 'when file exists' do
      it 'loads YAML' do
        expect(Envy.yaml).to be_a(Hash)
        expect(Envy.yaml).to include('development', 'production', 'KEY1')
      end
    end
    
    context 'when file does not exist' do
      before(:each) do
        Envy.stub(:file) { File.expand_path('../../fixtures/missing.yml', __FILE__) }
      end      
      it 'returns an empty hash' do        
        expect(Envy.yaml).to eq({})
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
  
end