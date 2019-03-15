Full documentation can be found at: https://www.rubydoc.info/gems/progressor

## Basic example

Here's an example long-running task:

``` ruby
Product.find_each do |product|
  next if product.not_something_we_want_to_process?
  product.calculate_interesting_stats
end
```

In order to understand how it's progressing, we might add some print statements:

``` ruby
Product.find_each do |product|
  if product.not_something_we_want_to_process?
    puts "Skipping product: #{product.id}"
    next
  end

  puts "Working on product: #{product.id}"
  product.calculate_interesting_stats
end
```

This gives us some indication of progress, but no idea how much time is left. We could take a count and maintain a manual index, and then eyeball it based on how fast the numbers are adding up. Progressor automates that process:

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

Each invocation of `run` measures how long its block took and records it. The yielded `progress` parameter is an object that can be `to_s`-ed to provide progress information.

The output might look like this:

```
...
[0038/1000, (004%), t/i: 0.5s, ETA: 8m:00s] Product 38
[0039/1000, (004%), t/i: 0.5s, ETA: 7m:58s] Product 39
[0040/1000, (004%), t/i: 0.5s, ETA: 7m:57s] Product 40
...
```

You can check the documentation for the [Progressor](https://www.rubydoc.info/gems/progressor/Progressor) class for details on the methods you can call to get the individual pieces of data shown in the report.

## Limited and unlimited sequences

Initializing a `Progressor` with a provided `total_count:` parameter gives you a limited sequence, which can give you not only a progress report, but an estimation of when it'll be done:

```
[<current loop>/<total count>, (<progress>%), t/i: <time per iteration>, ETA: <time until it's done>]
```

The calculation is done by maintaining a list of measurements with a limited size, and a list of averages of those measurements. The average of averages is the "time per iteration" and it's multiplied by the remaining count to produce the estimation.

I can't really say how reliable this is, but it seems to provide smoothly changing estimations that seem more or less correct to me, for similarly-sized chunks of work per iteration.

**Not** providing a `total_count:` parameter leads to less available information:

``` ruby
progressor = Progressor.new

(1..100).each do |i|
  progressor.run do |progress|
    sleep rand
    puts progress
  end
end
```

A sample of output might look like this:

```
...
11, t: 5.32s, t/i: 442.39ms
12, t: 5.58s, t/i: 446.11ms
...
```

The format is:

```
<current>, t: <time from start>, t/i: <time per iteration>
```

## Configuration

Apart from `total_count`, which is optional and affects the kind of sequence that will be stored, you can provide `min_samples` and `max_samples`. You can also provide a custom formatter:

``` ruby
progressor = Progressor.new({
  total_count: 1000,
  min_samples: 5,
  max_samples: 10,
  formatter: -> (p) { p.eta }
})
```

The option `min_samples` determines how many loops the tool will wait until trying to produce an estimation. A higher number means no information in the beginning, but no wild fluctuations, either. It needs to be at least 1 and the default is 1.

The option `max_samples` is how many measurements will be retained. Those measurements will be averaged, and then those averages averaged to get a time-per-iteration estimate. A smaller number means giving more weight to later events, while a larger one would average over a larger amount of samples. The default is 100.

The `formatter` is a callback that gets a progress object as an argument and you can return your own string to output on every loop.

## Related work

A very similar tool is the gem [ke](https://github.com/mkdynamic/ke). It provides its estimation by maintaining the median quartile range of the stored measurements, removing outliers. It also automates the output of the progress report, only printing it every N loops. Depending on your needs and preferences, it might be better for your use case.
