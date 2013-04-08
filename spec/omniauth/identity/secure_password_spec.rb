require 'spec_helper'

class HasTheMethod
  def self.has_secure_password; end
end

class DoesNotHaveTheMethod
end

class WithLegacyPassword
  attr_accessor :provider, :password_digest

  def initialize
    self.provider = 'Authlogic::Sha512'
  end
end

describe OmniAuth::Identity::SecurePassword do
  it 'should extend with the class methods if it does not have the method' do
    DoesNotHaveTheMethod.should_receive(:extend).with(OmniAuth::Identity::SecurePassword::ClassMethods)
    DoesNotHaveTheMethod.send(:include, OmniAuth::Identity::SecurePassword)
  end

  it 'should not extend if the method is already defined' do
    HasTheMethod.should_receive(:extend).with(OmniAuth::Identity::SecurePassword::ClassMethods)
    HasTheMethod.send(:include, OmniAuth::Identity::SecurePassword)
  end

  it 'should respond to has_secure_password afterwards' do
    [HasTheMethod,DoesNotHaveTheMethod].each do |klass|
      klass.send(:include, OmniAuth::Identity::SecurePassword)
      klass.should be_respond_to(:has_secure_password)
    end
  end

  describe 'with legacy password' do
    before do
      WithLegacyPassword.stub :validates_confirmation_of
      WithLegacyPassword.stub :validates_presence_of

      WithLegacyPassword.send :include, OmniAuth::Identity::SecurePassword
      WithLegacyPassword.has_secure_password
    end

    let(:model) { WithLegacyPassword.new }

    it 'should call LegacyPassword.create' do
      OmniAuth::Identity::LegacyPassword.should_receive(:create).with('qwerty', model)
      model.password = 'qwerty'
    end

    it 'should call LegacyPassword.new' do
      OmniAuth::Identity::LegacyPassword.should_receive(:matches?).with('qwerty', model)
      model.authenticate 'qwerty'
    end
  end
end
