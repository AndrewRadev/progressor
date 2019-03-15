class Progressor
  class UnlimitedSequence
    include Formatting

    attr_reader :min_samples, :max_samples

    # The current loop index, starts at 1
    attr_reader :current

    # The time the object was created
    attr_reader :start_time

    # Creates a new UnlimitedSequence with the given parameters:
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
    def initialize(min_samples: 1, max_samples: 100, formatter: nil)
      @min_samples = min_samples
      @max_samples = max_samples
      @formatter   = formatter

      raise Error.new("min_samples needs to be a positive number") if min_samples <= 0
      raise Error.new("max_samples needs to be larger than min_samples") if max_samples <= min_samples

      @start_time   = Time.now
      @current      = 0
      @measurements = []
      @averages     = []
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

    # "Skips" an iteration, which, in the context of an UnlimitedSequence is a no-op.
    #
    def skip(_n)
      # Nothing to do
    end

    # Outputs a textual representation of the current state of the
    # UnlimitedSequence. Shows:
    #
    # - the current (1-indexed) number of iterations
    # - how long since the start time
    # - how long a single iteration takes
    #
    # A custom `formatter` provided at construction time overrides this default
    # output.
    #
    def to_s
      return @formatter.call(self).to_s if @formatter

      [
        "#{@current + 1}",
        "t: #{format_time(Time.now - @start_time)}",
        "t/i: #{format_time(per_iteration)}",
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

    # Is supposed to return an estimation for the Estimated Time of Arrival
    # (time until done).
    #
    # For an UnlimitedSequence, this always returns nil.
    #
    def eta
      # No estimation possible
    end

    private

    def average(collection)
      collection.inject(&:+) / collection.count.to_f
    end
  end
end
