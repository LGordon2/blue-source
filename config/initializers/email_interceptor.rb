ActionMailer::Base.register_interceptor(EmailInterceptor) unless Rails.env.production? or Rails.env.staging?
