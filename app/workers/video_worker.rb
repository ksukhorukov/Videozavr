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

    ffprobe_command_duration = "ffprobe -i #{output_file} -show_entries format=duration -v quiet -of csv=\"p=0\""

    system(ffmpeg_command_convertion) unless File.extname(input_file) == '.mp4'
    system(ffmpeg_command_watermark)

    video.processed_video = output_file
    video.file_size = '%.2f' % (File.size(output_file).to_f / 2**20).to_s
    video.duration = '%.2f' % (`#{ffprobe_command_duration}`.to_f / 60).to_s
    video.save
  end
end
