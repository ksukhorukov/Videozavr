class VideoWorker
  include Sidekiq::Worker

  def perform(video_id)
    video = Video.find(video_id)

    input_file = video.movie.file.file

    watermark = video.watermark

    output_file = 'processed_videos/' + random_file_name('mp4')

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

    # unless File.extname(input_file) == '.mp4'
    #   system(ffmpeg_command_convertion)
    #   system("yes | cp -rf #{output_file} #{input_file}")
    # end

    system(ffmpeg_command_watermark)

    video.processed_video = output_file
    video.file_size = '%.2f' % (File.size(output_file).to_f / 2**20).to_s
    duration = (`#{ffprobe_command_duration}`.to_f / 60)
    video.duration = '%.2f' % duration.to_s

    screenshot_interval = duration * 60 / 4
    screenshot_time = screenshot_interval

    while(screenshot_time < duration * 60) do 
      file_path = 'screenshots_videos/' + random_file_name('jpg')
      time = Time.at(screenshot_time.to_i).utc.strftime("%H:%M:%S")
      ffmpeg_screenshot_command = "ffmpeg -ss #{time} -i #{input_file} -vframes 1 #{file_path}"
      system(ffmpeg_screenshot_command)
      byebug
      video.screenshots.create(file_path: file_path)
      screenshot_time += screenshot_time
    end

    video.save
  end



  def random_file_name(ext)
    (0...50).map { ('a'..'z').to_a[rand(26)] }.join + '.' + ext
  end
end
