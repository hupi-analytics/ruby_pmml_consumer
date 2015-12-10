# Ruby PMML Consumer

Generate a PMML file with your favorite machine learning library and use this gem to read the file and make prediciton in a ruby application. This gem is primarily intended to work with apache spark 1.5 PMML file, so some features from the PMML standard maybe missing.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pmml_consumer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pmml_consumer

## Usage

```ruby
pmml_string = File.open('my_pmml_file.xml', "rb").read
predictor = PMMLConsumer.load(pmml_string)
input = { "feature1" => 1, "feature2" => "banana"}
puts predictor.predict(input)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hupi-analytics/pmml_consumer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
