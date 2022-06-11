module Progressor::Iteration
  # Iterate the given collection, assuming it responds to:
  #
  # - The given `method` with a block that yields a single item
  # - optionally, `count` that returns the number of results
  #
  # It yields two items -- the item from the collection and a numeric index. It
  # prints the progress automatically for each loop.
  #
  # This is meant to be used as a convenience method for ActiveRecord
  # collections with `find_each` or `each`, but it could really be used for
  # anything that works with this interface.
  #
  # Inputs:
  #
  # - method:     the method name to invoke on `collection`
  # - collection: the iterable object
  # - format:     the method to use for printing each individual record. Defaults to `:to_s`
  # - options:    passed along to `Progressor::new`
  #
  def self.iterate(method, collection, format: :to_s, **options, &block)
    if !collection.respond_to?(method)
      raise Progressor::Error.new("Given collection doesn't respond to ##{method}")
    end

    if collection.respond_to?(:count)
      progressor = Progressor.new(total_count: collection.count, **options)
    else
      progressor = Progressor.new(**options)
    end

    index = 0

    collection.public_send(method) do |item|
      progressor.run do |progress|
        Kernel.puts "[#{progress}] Working on #{item.public_send(format)}"
        block.call(item, index)
        index += 1
      end
    end
  end

  # Iterates using `.iterate` and the `#find_each` method
  #
  def self.find_each(collection, **options, &block)
    iterate(:find_each, collection, **options, &block)
  end

  # Iterates using `.iterate` and the `#each` method
  #
  def self.each(collection, **options, &block)
    iterate(:each, collection, **options, &block)
  end
end
