class VideoWorker
  include Sidekiq::Worker

  def perform(video_id)
    video = Video.find(video_id)

    input_file = video.movie.file.file

    watermark = video.watermark

    output_file = 'processed_videos/' + (0...50).map { ('a'..'z').to_a[rand(26)] }.join + '.mp4'

    ffmpeg_command_convertion = %{
      ffmpeg -i #{input_file} -vcodec copy -acodec copy #{output_file}
    }

    ffmpeg_command_watermark = %{ 
      ffmpeg -i #{input_file} \
             -vf drawtext="fontfile=fonts/Verdana.ttf: \
             text='#{watermark}': fontcolor=white: fontsize=24: box=1: boxcolor=black@0.5: \
             boxborderw=5: x=(w-text_w)/2: y=(h-text_h)/2" \
             -codec:a copy #{output_file} }

    system(ffmpeg_command_convertion) unless File.extname(input_file) == '.mp4'
    system(ffmpeg_command_watermark)

    video.processed_video = output_file
    video.save
  end
end
