module OmniAuth
  module Identity
    module Recoverable
      def self.included(base)
        base.extend ClassMethods
      end

      # Update password saving the record and clearing token. Returns true if
      # the passwords are valid and the record was saved, false otherwise.
      def reset_password!(new_password, new_password_confirmation)
        self.password = new_password
        self.password_confirmation = new_password_confirmation

        clear_reset_password_token if valid?

        save
      end

      # Resets reset password token and send reset password instructions by email
      def send_reset_password_instructions
      end

      protected

      # Removes reset_password token
      def clear_reset_password_token
        self.reset_password_token = nil
        self.reset_password_sent_at = nil
      end

      def should_generate_reset_token?
        self.reset_password_token.nil?
      end

      # Generates a new random token for reset password
      def generate_reset_password_token
        self.reset_password_token = new_reset_password_token
        self.reset_password_sent_at = Time.now.utc
        self.reset_password_token
      end

      def generate_reset_password_token_if_require
        generate_reset_password_token! if should_generate_reset_token?
      end

      # Resets the reset password token with and save the record without
      # validating
      def generate_reset_password_token!
        generate_reset_password_token && save(:validate => false)
      end

      # Generate a token checking if one does not already exist in the database.
      def new_reset_password_token
        #It's only in Ruby 1.9
        #see https://github.com/rails/rails/commit/b3411ff59eb1e1c31f98f58f117a2ffaaf0c3ff5
        SecureRandom.base64.gsub("/","_").gsub(/=+$/,"")
      end

      module ClassMethods
        # Attempt to find a user by its email. If a record is found, send new
        # password instructions to it.
        def send_reset_password_instructions(email)
          recoverable = find_by_email(email)
          recoverable.generate_reset_password_token_if_require
          recoverable.send_reset_password_instructions
          recoverable
        end

        def reset_password_by_token(token, password, password_confirmation)
          recoverable = find_by_reset_password_token(token)
          recoverable.reset_password!(password, password_confirmation)
          recoverable
        end
      end
    end
  end
end
