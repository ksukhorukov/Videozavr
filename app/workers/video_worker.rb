require 'fileutils'

class VideoWorker
  include Sidekiq::Worker

  def perform(video_id, update = false)
    video = Video.find(video_id)

    if update
      FileUtils.rm('public/videos/' + video.processed_video)
      video.screenshots.each do |shot|
        FileUtils.rm 'public/images/' + shot.file_path
        shot.destroy
      end
    end

    input_file = video.movie.file.file

    watermark = video.watermark

    FileUtils.mkdir_p 'public/videos'
    FileUtils.mkdir_p 'public/videos/processed_videos'

    output_file = 'public/videos/processed_videos/' + random_file_name('mp4')

    ffmpeg_command_watermark = %{ 
      ffmpeg -i #{input_file} \
             -vf drawtext="fontfile=fonts/Verdana.ttf: \
             text='#{watermark}': fontcolor=white: fontsize=24: box=1: boxcolor=black@0.5: \
             boxborderw=5: x=(w-text_w)/2: y=(h-text_h)/2" \
             -codec:a copy #{output_file} }

    ffprobe_command_duration = "ffprobe -i #{output_file} -show_entries format=duration -v quiet -of csv=\"p=0\""

    system(ffmpeg_command_watermark)

    video.processed_video = output_file.gsub('public/videos/','')
    video.file_size = '%.2f' % (File.size(output_file).to_f / 2**20).to_s
    duration = (`#{ffprobe_command_duration}`.to_f / 60)
    video.duration = '%.2f' % duration.to_s

    screenshot_interval = duration * 60 / 4
    screenshot_time = screenshot_interval

    FileUtils.mkdir_p 'public/images'
    FileUtils.mkdir_p 'public/images/screenshots_videos/'

    while(screenshot_time < duration * 60) do 
      file_path = 'public/images/screenshots_videos/' + random_file_name('jpg')
      time = Time.at(screenshot_time.to_i).utc.strftime("%H:%M:%S")
      ffmpeg_screenshot_command = "ffmpeg -ss #{time} -i #{output_file} -vframes 1 #{file_path}"
      system(ffmpeg_screenshot_command)
      video.screenshots.create(file_path: file_path.gsub('public/images/',''))
      screenshot_time += screenshot_time
    end
    video.ready = true
    video.save
  end



  def random_file_name(ext)
    (0...50).map { ('a'..'z').to_a[rand(26)] }.join + '.' + ext
  end
end
