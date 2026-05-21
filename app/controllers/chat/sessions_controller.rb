module Chat
  class SessionsController < ApplicationController
    def new
    end

    def create
      session[:user_name] = params[:user_name]
      redirect_to chat_rooms_path
    end
  end
end
