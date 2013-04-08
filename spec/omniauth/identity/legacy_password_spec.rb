require 'spec_helper'

class WithLegacyPassword
  attr_accessor :provider, :password_digest

  def initialize
    self.provider = 'Authlogic::Sha512'
  end
end

describe OmniAuth::Identity::LegacyPassword do
  let(:model) { WithLegacyPassword.new }

  describe 'create class methods' do
    it 'should call OmniAuth::Identity::LegacyPassword::Authlogic.encrypt' do
      OmniAuth::Identity::LegacyPassword::Authlogic.should_receive(:encrypt).with('qwerty', model)
      OmniAuth::Identity::LegacyPassword.create('qwerty', model)
    end
  end

  describe 'new methods' do
    it 'should call OmniAuth::Identity::LegacyPassword::Authlogic.matches?' do
      OmniAuth::Identity::LegacyPassword::Authlogic.should_receive(:matches?).with('qwerty', model)
      OmniAuth::Identity::LegacyPassword.matches?('qwerty', model)
    end
  end
end
