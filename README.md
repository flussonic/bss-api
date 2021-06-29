# BSS API

Unified API

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bss_api', git: 'https://github.com/flussonic/bss-api.git'
```

And then execute:

    $ bundle install

### Configuration

`api_key` - API token. *required*

`api_key_prefix` - Prefix for API token. For example, 'Bearer'.

`host_class` - Host model used in `BssApi::HostableDataCollector`.

`log_class` - Model for logging API requests in `BssApi::HostableDataCollector`.

## Usage

### Create decorator for your model

It must be named `BssApi::Decorators::[model_name]::Decorator`, where _model_name_ is your model class name.

### Create controller and routes

#### Required controller methods

`default_scope` - to determine the model and it's scope, that will be included to the result.

`permitted_params` - to determine permitted parameters of model.

#### Optional controller methods
`data_collector` - class of the data collector. By default it is `BssApi::DataCollector`.

`model_name` - name of model used for rendering the results and defining alias for id parameter. By default it is downcased model class name from `default_scope`.

`model_id` - alias key for id parameter. By default it is `model_name` plus `_id`.

`collection_name` - name of collection used for rendering the results (keys in JSON and filename in CSV). By default it is pluralized `model_name`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
