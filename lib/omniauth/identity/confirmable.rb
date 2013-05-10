module OmniAuth
  module Identity
    module Confirmable
      def self.included(base)
        base.extend ClassMethods

        base.class_eval do
          before_create :generate_confirmation_token
          after_create  :send_on_create_confirmation_instructions
        end
      end

      ## Confirm a user by setting it's confirmed_at to actual time. If the user
      ## is already confirmed, add an error to email field. If the user is invalid
      ## add errors
      def confirm!
        self.confirmation_token = nil
        self.confirmed_at = Time.now.utc
        save(:validate => false)
      end

      ## Verifies whether a user is confirmed or not
      def confirmed?
        !!confirmed_at
      end

      # Send confirmation instructions by email
      def send_confirmation_instructions
        self.confirmation_token = nil
        generate_confirmation_token
        send_on_create_confirmation_instructions
      end

      ## If you don't want confirmation to be sent on create, neither a code
      ## to be generated, call skip_confirmation!
      def skip_confirmation!
        self.confirmed_at = Time.now.utc
      end

      protected

      ## A callback method used to deliver confirmation
      ## instructions on creation. This can be overriden
      ## in models to map to a nice sign up e-mail.
      def send_on_create_confirmation_instructions
      end

      ## Generates a new random token for confirmation, and stores the time
      ## this token is being generated
      def generate_confirmation_token
        self.confirmation_token = new_confirmation_token
        self.confirmation_sent_at = Time.now.utc
      end

      ## Generate a token checking if one does not already exist in the database.
      def new_confirmation_token
        #It's only in Ruby 1.9
        #see https://github.com/rails/rails/commit/b3411ff59eb1e1c31f98f58f117a2ffaaf0c3ff5
        SecureRandom.base64.gsub("/","_").gsub(/=+$/,"")
      end

      module ClassMethods
        # Attempt to find a user by its email. If a record is found, send new
        # confirmation instructions to it
        def send_confirmation_instructions(email)
          confirmable = find_by_email(email)
          confirmable.send_confirmation_instructions
          confirmable
        end

        def confirm_by_token(confirmation_token)
          confirmable = find_by_confirmation_token(confirmation_token)
          confirmable.confirm!
          confirmable
        end
      end
    end
  end
end
