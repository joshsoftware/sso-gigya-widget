# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_sso-gigya-widget_session',
  :secret      => '5954b4e089920fd76d162a11757a9034e4e822ed4526b855133084820923c19cccdf6690e77d847de6c6858510c7e9125bf7016398e7d901b0f54f21a2c0e11d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
