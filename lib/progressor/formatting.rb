class Progressor
  module Formatting
    def format_time(time)
      return "?s" if time.nil?

      if time < 0.1
        "#{(time * 1000).round(2)}ms"
      elsif time < 60
        "#{format_float(time.round(2))}s"
      elsif time < 3600
        minutes = time.to_i / 60
        seconds = (time - minutes * 60).round(2)
        "#{format_int(minutes)}m:#{format_float(seconds)}s"
      else
        hours = time.to_i / 3600
        minutes = (time.to_i % 3600) / 60
        seconds = (time - (hours * 3600 + minutes * 60)).round(2)
        "#{format_int(hours)}h:#{format_int(minutes)}m:#{format_float(seconds)}s"
      end
    end

    def format_int(value)
      value.to_s
    end

    def format_float(value)
      value.to_s
    end
  end
end
