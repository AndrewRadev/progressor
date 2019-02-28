require 'progressor/version'

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
#   [0038/1000, (004%), t/i: 0.5s, ETA: 8m:0.27s] Product 38
#   [0039/1000, (004%), t/i: 0.5s, ETA: 7m:58.47s] Product 39
#   [0040/1000, (004%), t/i: 0.5s, ETA: 7m:57.08s] Product 40
#   ...
#
class Progressor
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

  def initialize(total_count:)
    @total_count = total_count
    @total_count_digits = total_count.to_s.length
    @current = 0
    @measurements = []
    @averages = []
  end

  def run
    @current += 1

    measurement = Benchmark.measure { yield self }

    @measurements << measurement.real
    # only keep last 1000
    @measurements.shift if @measurements.count > 1000

    @averages << average(@measurements)
    @averages = @averages.compact
    # only keep last 100
    @averages.shift if @averages.count > 100
  end

  def skip(n)
    @total_count -= n
  end

  def to_s
    [
      "#{@current.to_s.rjust(@total_count_digits, '0')}/#{@total_count}",
      "(#{((@current / @total_count.to_f) * 100).round.to_s.rjust(3, '0')}%)",
      "t/i: #{self.class.format_time(per_iteration)}",
      "ETA: #{self.class.format_time(eta)}",
    ].join(', ')
  end

  def per_iteration
    return nil if @measurements.count < 10
    average(@averages)
  end

  def eta
    return nil if @measurements.count < 10

    remaining_time = per_iteration * (@total_count - @current)
    remaining_time.round(2)
  end

  private

  def self.format_time(time)
    return "?s" if time.nil?

    if time < 0.1
      "#{(time * 1000).round(2)}ms"
    elsif time < 60
      "#{time.round(2)}s"
    elsif time < 3600
      minutes = time.to_i / 60
      seconds = (time - minutes * 60).round(2)
      "#{minutes}m:#{seconds}s"
    else
      hours = time.to_i / 3600
      minutes = (time.to_i % 3600) / 60
      seconds = (time - (hours * 3600 + minutes * 60)).round(2)
      "#{hours}h:#{minutes}m:#{seconds}s"
    end
  end

  def average(collection)
    collection.inject(&:+) / collection.count.to_f
  end
end
