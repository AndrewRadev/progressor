class Progressor
  module Formatting
    def format_time(time)
      return "?s" if time.nil?

      if time < 1
        "#{format_float((time * 1000).round(2))}ms"
      elsif time < 60
        "#{format_float(time.round(2))}s"
      elsif time < 3600
        minutes = time.to_i / 60
        seconds = (time - minutes * 60).round(2)
        "#{format_int(minutes)}m:#{format_int(seconds)}s"
      else
        hours = time.to_i / 3600
        minutes = (time.to_i % 3600) / 60
        seconds = (time - (hours * 3600 + minutes * 60)).round(2)
        "#{format_int(hours)}h:#{format_int(minutes)}m:#{format_int(seconds)}s"
      end
    end

    def format_int(value)
      sprintf("%02d", value)
    end

    def format_float(value)
      sprintf("%0.2f", value)
    end
  end
end
