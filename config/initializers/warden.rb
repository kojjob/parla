# Ensure Warden is properly initialized and available
Rails.application.config.middleware.use Warden::Manager do |manager|
  # Configure Warden to use the same settings as Devise
  manager.default_strategies(scope: :user).unshift :database_authenticatable
  manager.failure_app = Devise::FailureApp
end

# Add a callback to ensure Warden is properly set up
Warden::Manager.after_set_user do |user, auth, opts|
  # This ensures the user is properly set in the Warden scope
  scope = opts[:scope]
  auth.session(scope)[:logged_in_at] = Time.now.utc.to_i
end
