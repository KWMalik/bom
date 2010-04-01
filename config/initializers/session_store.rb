# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_bom_session',
  :secret      => '108d4251223b733b13e84d06df1d98612c9bfccb349ddfe4edee536ed2bd19d11fd9980fd2925d18cfc880d202501d530334e3c3f8554a9e529efd102cb651b9'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
