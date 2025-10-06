class LikesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def show
    like = Like.find_by(identifier: params[:page_identifier])
    render json: { count: like ? like.count : 0 }
  end

  def create
    count = Like.increment_for(params[:page_identifier])
    render json: { count: count }
  end
end
