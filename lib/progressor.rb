require 'progressor/version'
require 'progressor/error'
require 'progressor/formatting'
require 'progressor/limited_sequence'
require 'progressor/unlimited_sequence'

require 'benchmark'

# Used to measure the running time of parts of a long-running task and output
# an estimation based on the average of the last 10-100 measurements.
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
#   [0038/1000, 004%, t/i: 0.5s, ETA: 8m:0.27s] Product 38
#   [0039/1000, 004%, t/i: 0.5s, ETA: 7m:58.47s] Product 39
#   [0040/1000, 004%, t/i: 0.5s, ETA: 7m:57.08s] Product 40
#   ...
#
class Progressor
  include Formatting

  # Utility method to print a message with the time it took to run the contents
  # of the block.
  #
  # > Progressor.puts("Working on a thing") { thing_work }
  #
  # Working on a thing...
  # Working on a thing DONE: 2.1s
  #
  def self.puts(message, &block)
    Kernel.puts "#{message}..."
    measurement = Benchmark.measure { block.call }
    Kernel.puts "#{message} DONE: #{format_time(measurement.real)}"
  end

  def initialize(total_count: nil, min_samples: 10, max_samples: 100, formatter: nil)
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

  def run
    measurement = Benchmark.measure { yield self }
    @sequence.push(measurement.real)
  end

  def skip(n)
    @sequence.skip(n)
  end

  def to_s
    @sequence.to_s
  end

  def per_iteration
    @sequence.per_iteration
  end

  def eta
    @sequence.eta
  end
end
