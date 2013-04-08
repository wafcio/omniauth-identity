module OmniAuth
  module Identity
    class LegacyPassword
      class Authlogic
        def self.choose(object, &block)
          case object.provider.split('::').last
            when 'Sha512' then block.call(Sha512)
          end
        end

        def self.encrypt(unencrypted_password, object)
          choose(object) do |klass|
            klass.encrypt([unencrypted_password, object.password_salt])
          end
        end

        def self.matches?(unencrypted_password, object)
          choose(object) do |klass|
            tokens = [unencrypted_password, object.password_salt]
            klass.matches?(object.password_digest, tokens)
          end
        end
      end
    end
  end
end