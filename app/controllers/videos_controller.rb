class VideosController < ApplicationController
  before_action :signed_in_user, only: [:create, :edit, :destroy]
  before_action :set_video, only: [:edit, :update]
  before_action :correct_user,   only: :destroy

  def create
    @video = current_user.videos.build(video_params)
    if @video.save
      flash[:success] = "Video upload successfully! Processing video. Wait a minute and then refresh the page..."
      VideoWorker.perform_async(@video.id)
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def edit
  end

  def update
    if @video.update(video_params)
      @video.ready = false
      @video.save
      flash[:success] = "Video edited successfully! Processing video. Wait a minute and then refresh the page..."
      VideoWorker.perform_async(@video.id, true)
      redirect_to root_url
    else
      render 'edit'
    end
  end

  def destroy
    @video.destroy
    redirect_to root_url
  end

  private

    def video_params
      params.require(:video).permit(:watermark, :movie)
    end

    def correct_user
      @video = current_user.videos.find_by(id: params[:id])
      redirect_to root_url if @video.nil?
    end

    def set_video
      @video = Video.find(params[:id])
    end
end
