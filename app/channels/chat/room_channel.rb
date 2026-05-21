module Chat
  class RoomChannel < ApplicationCable::Channel
    def subscribed
      stream_from "room_channel_#{params[:room_id]}"
    end

    def unsubscribed
      # Any cleanup needed when channel is unsubscribed
    end

    def typing(data)
      # Broadcast typing status
      ActionCable.server.broadcast("room_channel_#{params[:room_id]}", {
        type: "typing",
        status: data["status"],
        user_name: current_user_name
      })
    end

    private

    def current_user_name
      connection.respond_to?(:user_name) ? connection.user_name : "TestUser"
    end
  end
end
