class StaticPagesController < ApplicationController

  def home
    if signed_in?
      @video  = current_user.videos.build
      @feed_items = current_user.videos.where(ready: true).includes(:screenshots).paginate(page: params[:page])
    end
  end
  
end
