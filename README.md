# fluent-plugin-gcloud-storage

[Cloud Storage](https://cloud.google.com/storage/) Output plugin for [Fluentd](http://www.fluentd.org/) with [gcloud](https://googlecloudplatform.github.io/gcloud-ruby/) gem.

Sponsored by [BIDMATH](http://bidmath.com)

## Installation

Please follow the [Plugin Management](http://docs.fluentd.org/articles/plugin-management) guide of fluentd.

```ruby
# If you're using fluentd
fluent-gem install 'fluent-plugin-gcloud-storage'

# If you're using td-agent
td-agent-gem install 'fluent-plugin-gcloud-storage'
```

## Preparation

- Create a project on Google Developer Console
- Create a bucket within your project
- Download your credential (json)

## Configuration
publish dummy json data like `{"message": "dummy", "value": 0}\n{"message": "dummy", "value": 1}\n ...`.

```
<source>
  type dummy
  tag example.publish
  auto_increment_key value
</source>

<match example.publish>
  type           gcloud_storage

  key            <PATH YOUR KEY JSON FILE>
  project        <YOUR PROJECT ID>
  bucket         <YOUR BUCKET ID>
  path           /path/to/the/output/file

  buffer_path    <PATH OF THE BUFFER>
</match>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/fluent-plugin-gcloud-storage. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

