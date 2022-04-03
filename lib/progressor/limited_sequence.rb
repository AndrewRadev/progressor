class Progressor
  class LimitedSequence
    include Formatting

    attr_reader :total_count, :min_samples, :max_samples

    # The current loop index, starts at 1
    attr_reader :current

    # The time the object was created
    attr_reader :start_time

    # Creates a new LimitedSequence with the given parameters:
    #
    # - total_count: The expected number of loops.
    #
    # - min_samples: The number of samples to collect before attempting to
    #   calculate a time per iteration. Default: 1
    #
    # - max_samples: The maximum number of measurements to collect and average.
    #   Default: 100.
    #
    # - formatter: A callable that accepts the sequence object and returns a
    #   custom formatted string.
    #
    def initialize(total_count:, min_samples: 1, max_samples: 100, formatter: nil)
      @total_count = total_count
      @min_samples = min_samples
      @max_samples = [max_samples, total_count].min
      @formatter   = formatter

      raise Error.new("min_samples needs to be a positive number") if min_samples <= 0
      raise Error.new("max_samples needs to be larger than min_samples") if max_samples <= min_samples

      @start_time         = Time.now
      @total_count_digits = total_count.to_s.length
      @current            = 0
      @measurements       = []
      @averages           = []
    end

    # Adds a duration in seconds to the internal storage of samples. Updates
    # averages accordingly.
    #
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

    # Skips an iteration, updating the total count and ETA
    #
    def skip(n)
      @total_count -= n
    end

    # Outputs a textual representation of the current state of the
    # LimitedSequence. Shows:
    #
    # - the current number of iterations and the total count
    # - completion level in percentage
    # - how long a single iteration takes
    # - estimated time of arrival (ETA) -- time until it's done
    #
    # A custom `formatter` provided at construction time overrides this default
    # output.
    #
    # If the "current" number of iterations goes over the total count, an ETA
    # can't be shown anymore, so it'll just be the current number over the
    # expected one, and the time per iteration.
    #
    def to_s
      return @formatter.call(self).to_s if @formatter

      if @current > @total_count
        return [
          "#{@current} (expected #{@total_count})",
          "t/i: #{format_time(per_iteration)}",
          "ETA: ???",
        ].join(', ')
      end

      [
        "#{@current.to_s.rjust(@total_count_digits, '0')}/#{@total_count}",
        "#{((@current / @total_count.to_f) * 100).round.to_s.rjust(3, '0')}%",
        "t/i: #{format_time(per_iteration)}",
        "ETA: #{format_time(eta)}",
      ].join(', ')
    end

    # Returns an estimation for the time per single iteration. Implemented as
    # an average of averages to provide a smoother gradient from loop to loop.
    #
    # Returns nil if not enough samples have been collected yet.
    #
    def per_iteration
      return nil if @measurements.count < min_samples
      average(@averages)
    end

    # Returns an estimation for the Estimated Time of Arrival (time until
    # done).
    #
    # Calculated by multiplying the average time per iteration with the
    # remaining number of loops.
    #
    def eta
      return nil if @measurements.count < min_samples

      remaining_time = per_iteration * (@total_count - @current)
      remaining_time.round(2)
    end

    # Returns the time since the object was instantiated, formatted like all
    # the other durations. Useful for a final message to compare initial
    # estimation to actual elapsed time.
    #
    def elapsed_time
      format_time(Time.now - @start_time)
    end

    private

    def average(collection)
      collection.inject(&:+) / collection.count.to_f
    end
  end
end
