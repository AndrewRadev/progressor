class Progressor
  class LimitedSequence
    include Formatting

    attr_reader :total_count, :min_samples, :max_samples

    def initialize(total_count:, min_samples: 10, max_samples: 100)
      @total_count = total_count
      @min_samples = min_samples
      @max_samples = max_samples

      raise Error.new("min_samples needs to be a positive number") if min_samples <= 0
      raise Error.new("max_samples needs to be larger than min_samples") if max_samples <= min_samples

      @total_count_digits = total_count.to_s.length
      @current            = 0
      @measurements       = []
      @averages           = []
    end

    def push(duration)
      @current += 1
      @measurements << duration
      # only keep last `max_samples`
      @measurements.shift if @measurements.count > max_samples

      @averages << average(@measurements)
      @averages = @averages.compact
      # only keep last `max_samples`
      @averages.shift if @averages.count > max_samples
    end

    def skip(n)
      @total_count -= n
    end

    def to_s
      [
        "#{@current.to_s.rjust(@total_count_digits, '0')}/#{@total_count}",
        "(#{((@current / @total_count.to_f) * 100).round.to_s.rjust(3, '0')}%)",
        "t/i: #{format_time(per_iteration)}",
        "ETA: #{format_time(eta)}",
      ].join(', ')
    end

    def per_iteration
      return nil if @measurements.count < min_samples
      average(@averages)
    end

    def eta
      return nil if @measurements.count < min_samples

      remaining_time = per_iteration * (@total_count - @current)
      remaining_time.round(2)
    end

    def average(collection)
      collection.inject(&:+) / collection.count.to_f
    end
  end
end
