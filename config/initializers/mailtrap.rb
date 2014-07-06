# Sets up the mailtrap server for testing purposes.  See https://mailtrap.io/.
# This is required for running the server in any environment besides
# production.  If this is not setup correctly, all emails will be sent to
# the real addresses specified in the app.

if ENV['MAILTRAP_HOST'].present?
  BlueSource::Application.config.action_mailer.delivery_method = :smtp
  BlueSource::Application.config.action_mailer.smtp_settings = {
    user_name: ENV['MAILTRAP_USER_NAME'],
    password: ENV['MAILTRAP_PASSWORD'],
    address: ENV['MAILTRAP_HOST'],
    port: ENV['MAILTRAP_PORT'],
    authentication: :plain
  }
elsif !Rails.env.production?
  BlueSource::Application.config.action_mailer.perform_deliveries = false
end
