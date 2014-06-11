class EmailInterceptor
  def self.delivering_email(message)
    message.cc = message.to = ['david.quach@orasi.com']
  end
end
