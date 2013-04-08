require 'spec_helper'

class WithLegacyPassword
  attr_accessor :provider, :password_digest, :password_salt, :password_digest

  def initialize
    self.provider = 'Authlogic::Sha512'
    self.password_salt = 'asdfgh'
    self.password_digest = 'zxcvbn'
  end
end

describe OmniAuth::Identity::LegacyPassword::Authlogic do
  let(:model) { WithLegacyPassword.new }

  describe 'create class methods' do
    it 'should call OmniAuth::Identity::LegacyPassword::Authlogic::Sha512.encrypt' do
      OmniAuth::Identity::LegacyPassword::Authlogic::Sha512.should_receive(:encrypt).with(['qwerty', model.password_salt])
      OmniAuth::Identity::LegacyPassword::Authlogic.encrypt('qwerty', model)
    end
  end

  describe 'matches? class methods' do
    it 'should call OmniAuth::Identity::LegacyPassword::Authlogic::Sha512.matches?' do
      OmniAuth::Identity::LegacyPassword::Authlogic::Sha512.should_receive(:matches?).with(model.password_digest, ['qwerty', model.password_salt])
      OmniAuth::Identity::LegacyPassword::Authlogic.matches?('qwerty', model)
    end
  end
end
