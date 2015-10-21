# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 'fluent-plugin-gcloud-storage'
  spec.version       = '0.1.0'
  spec.authors       = ['Gergő Sulymosi']
  spec.email         = ['gergo.sulymosi@gmail.com']

  spec.summary       = 'Google Cloud Storage output plugin for fluentd event collector'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/trekdemo/fluent-plugin-gcloud-storage'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'test-unit'

  spec.add_runtime_dependency 'fluentd', '> 0.10.42'
  spec.add_runtime_dependency 'gcloud', '~> 0.4.0'
  spec.add_runtime_dependency 'httpclient', '~> 2.6'
end
