class Progressor
  class UnlimitedSequence
    include Formatting

    attr_reader :min_samples, :max_samples

    def initialize(min_samples: 10, max_samples: 100)
      @min_samples = min_samples
      @max_samples = max_samples

      raise Error.new("min_samples needs to be a positive number") if min_samples <= 0
      raise Error.new("max_samples needs to be larger than min_samples") if max_samples <= min_samples

      @start_time   = Time.now
      @current      = 0
      @measurements = []
      @averages     = []
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

    def skip(_n)
      # Nothing to do
    end

    def to_s
      [
        "#{@current + 1}",
        "t: #{format_time(Time.now - @start_time)}",
        "t/i: #{format_time(per_iteration)}",
      ].join(', ')
    end

    def per_iteration
      return nil if @measurements.count < min_samples
      average(@averages)
    end

    def eta
      # No estimation possible
    end

    def average(collection)
      collection.inject(&:+) / collection.count.to_f
    end
  end
end
