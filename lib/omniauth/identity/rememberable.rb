module OmniAuth
  module Identity
    module Rememberable
      def self.included(base)
        base.extend ClassMethods
      end

      # Generate a new remember token and save the record without validations
      # unless remember_across_browsers is true and the user already has a valid token.
      def remember_me!
        self.remember_token = new_remember_token_token
        self.remember_created_at = Time.now.utc
        save(:validate => false)
      end

      def forget_me!
        self.remember_token = nil
        self.remember_created_at = nil
        save(:validate => false)
      end

      # Create the cookie key using the record id and remember_token
      def serialize_into_cookie
        [uid, self.remember_token]
      end

      protected

      # Generate a token checconfirmableking if one does not already exist in the database.
      def new_remember_token_token
        #It's only in Ruby 1.9
        #see https://github.com/rails/rails/commit/b3411ff59eb1e1c31f98f58f117a2ffaaf0c3ff5
        SecureRandom.base64.gsub("/","_").gsub(/=+$/,"")
      end

      module ClassMethods
        # Recreate the user based on the stored cookie
        def serialize_from_cookie(id, remember_token)
          user = find(id)
          user if user && user.remember_token == remember_token
        end
      end
    end
  end
end
