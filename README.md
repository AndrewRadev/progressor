A very basic library to measure loops in a long-running task.

*Note: Very incomplete, so mostly for personal usage. Will hopefully flesh it out, write tests, configuration, etc, at some point (PRs welcome). Until then, a similar library can be found here: https://github.com/mkdynamic/ke*

Example usage:

``` ruby
progressor = Progressor.new(total_count: Product.count)

Product.find_each do |product|
  if product.not_something_we_want_to_process?
    progressor.skip(1)
    next
  end

  progressor.run do |progress|
    puts "[#{progress}] Product #{product.id}"
    product.calculate_interesting_stats
  end
end
```

Example output:

```
...
[0038/1000, (004%), t/i: 0.5s, ETA: 8m:0.27s] Product 38
[0039/1000, (004%), t/i: 0.5s, ETA: 7m:58.47s] Product 39
[0040/1000, (004%), t/i: 0.5s, ETA: 7m:57.08s] Product 40
...
```

Bonus helper method to just measure how long a block of code took:

``` ruby
Progressor.puts("Working on a thing") do
  thing_work
end
```

Outputs to stdout:

```
Working on a thing...
Working on a thing DONE: 2.1s
```
