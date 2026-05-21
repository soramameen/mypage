module Chat
  class MessagesController < ApplicationController
    def create
      @room = Room.find(params[:room_id])
      @message = @room.messages.new(message_params)
      @message.user_name = session[:user_name]

      respond_to do |format|
        if @message.save
          format.html { redirect_to chat_room_path(@room) }
          format.turbo_stream
        else
          format.html { redirect_to chat_room_path(@room), status: :unprocessable_entity }
          format.turbo_stream { render :new, status: :unprocessable_entity }
        end
      end
    end

    def edit
      @message = Message.find(params[:id])
    end

    def update
      @message = Message.find(params[:id])

      respond_to do |format|
        if @message.update(message_params)
          format.html { redirect_to chat_room_path(@message.room) }
          format.turbo_stream
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.turbo_stream { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @message = Message.find(params[:id])
      @room = @message.room
      @message.destroy

      respond_to do |format|
        format.html { redirect_to chat_room_path(@room) }
        format.turbo_stream
      end
    end

    private

    def message_params
      params.require(:message).permit(:content)
    end
  end
end
