module Chat
  class ReactionsController < ApplicationController
    def create
      @room = Room.find(params[:room_id])
      @message = Message.find(params[:message_id])
      @user_name = session[:user_name]
      @emoji = params[:emoji]

      # Check if reaction already exists
      existing_reaction = Reaction.find_by(
        message: @message,
        user_name: @user_name,
        emoji: @emoji
      )

      if existing_reaction
        # Toggle: delete existing reaction
        existing_reaction.destroy
        respond_to do |format|
          format.html { head :created }
          format.turbo_stream
          format.json { head :created }
          format.any { head :created }
        end
      else
        # Create new reaction
        @reaction = @message.reactions.new(
          emoji: @emoji,
          user_name: @user_name
        )

        if @reaction.save
          respond_to do |format|
            format.html { head :created }
            format.turbo_stream
            format.json { head :created }
            format.any { head :created }
          end
        else
          render json: { errors: @reaction.errors }, status: :unprocessable_entity
        end
      end
    end

    def destroy
      @room = Room.find(params[:room_id])
      @message = Message.find(params[:message_id])
      @reaction = Reaction.find(params[:id])

      # Only allow users to delete their own reactions
      if @reaction.user_name == session[:user_name]
        @reaction.destroy
        respond_to do |format|
          format.html { head :no_content }
          format.turbo_stream
          format.json { head :no_content }
          format.any { head :no_content }
        end
      else
        head :forbidden
      end
    end
  end
end
