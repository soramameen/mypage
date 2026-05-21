module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user_name

    def connect
      self.user_name = request.session[:user_name] || "Anonymous"
    end
  end
end
