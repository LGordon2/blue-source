class EmailInterceptor
  def self.delivering_email(message)
    message.cc = message.to = ['lewis.gordon@orasi.com']
  end
end
