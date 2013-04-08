module OmniAuth
  module Identity
    class LegacyPassword
      def self.choose(object, &block)
        case object.provider.split('::').first
          when 'Authlogic' then block.call(Authlogic)
        end
      end

      def self.create(unencrypted_password, object)
        choose(object) do |klass|
          klass.encrypt(unencrypted_password, object)
        end
      end

      def self.matches?(unencrypted_password, object)
        choose(object) do |klass|
          klass.matches?(unencrypted_password, object)
        end
      end
    end
  end
end