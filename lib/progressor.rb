require 'progressor/version'
require 'progressor/error'
require 'progressor/formatting'
require 'progressor/limited_sequence'
require 'progressor/unlimited_sequence'

require 'benchmark'

# Used to measure the running time of parts of a long-running task and output
# an estimation based on the average of the last 1-100 measurements.
#
# Example usage:
#
#   progressor = Progressor.new(total_count: Product.count)
#
#   Product.find_each do |product|
#     if product.not_something_we_want_to_process?
#       progressor.skip(1)
#       next
#     end
#
#     progressor.run do |progress|
#       puts "[#{progress}] Product #{product.id}"
#       product.calculate_interesting_stats
#     end
#   end
#
# Example output:
#
#   ...
#   [0038/1000, 004%, t/i: 0.5s, ETA: 8m:00s] Product 38
#   [0039/1000, 004%, t/i: 0.5s, ETA: 7m:58s] Product 39
#   [0040/1000, 004%, t/i: 0.5s, ETA: 7m:57s] Product 40
#   ...
#
class Progressor
  include Formatting

  # Utility method to print a message with the time it took to run the contents
  # of the block.
  #
  #   Progressor.puts("Working on a thing") { thing_work }
  #
  # Output:
  #
  #   Working on a thing...
  #   Working on a thing DONE: 2.1s
  #
  def self.puts(message, &block)
    Kernel.puts "#{message}..."
    measurement = Benchmark.measure { block.call }
    Kernel.puts "#{message} DONE: #{format_time(measurement.real)}"
  end

  # Set up a new Progressor instance. Optional parameters:
  #
  # - total_count: If given, the tool will be able to provide an ETA.
  #
  # - min_samples: The number of samples to collect before attempting to
  #   calculate a time per iteration. Default: 1
  #
  # - max_samples: The maximum number of measurements to collect and average.
  #   Default: 100.
  #
  # - formatter: A callable that accepts a progress object and returns a
  #   custom formatted string.
  #
  def initialize(total_count: nil, min_samples: 1, max_samples: 100, formatter: nil)
    params = {
      min_samples: min_samples,
      max_samples: max_samples,
      formatter:   formatter,
    }

    if total_count
      @sequence = LimitedSequence.new(total_count: total_count, **params)
    else
      @sequence = UnlimitedSequence.new(**params)
    end
  end

  # Run the given block of code, yielding a sequence object that holds progress
  # information.
  #
  # Example usage:
  #
  #   progressor.run { |progress| puts progress; long_running_task() }
  #
  def run
    measurement = Benchmark.measure { yield @sequence }
    @sequence.push(measurement.real)
  end

  # Skips the given number of loops (will likely be 1), updating the
  # estimations appropriately.
  #
  def skip(n)
    @sequence.skip(n)
  end
end
