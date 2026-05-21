module Chat
  class RoomsController < ApplicationController
    def index
      @rooms = Room.all
      @room = Room.new
    end

    def show
      @room = Room.find(params[:id])
      @messages = @room.messages.order(created_at: :asc)
      @message = Message.new
    end

    def create
      @room = Room.new(room_params)

      respond_to do |format|
        if @room.save
          format.html { redirect_to chat_room_path(@room) }
          format.turbo_stream
        else
          @rooms = Room.all
          format.html { render :index, status: :unprocessable_entity }
          format.turbo_stream { render :index, status: :unprocessable_entity }
        end
      end
    end

    private

    def room_params
      params.require(:room).permit(:name)
    end
  end
end
