require 'fluent/test'
require 'fluent/plugin/out_gcloud_storage'

module Fluent
  RSpec.describe GcloudStorageOutput do
    before { Fluent::Test.setup }

    def create_driver(conf)
      Test::TimeSlicedOutputTestDriver.new(described_class) do
        # Do not upload
        def write(chunk)
          chunk.read
        end
      end.configure(conf)
    end

    def stub_gcloud
      # TODO Is there a fake Gcloud class?
      storage_double = double(bucket: :dummy_bucket)
      gcloud_double = double(storage: storage_double)
      allow(Gcloud)
        .to receive(:new)
        .with('test_project', 'test_key.json')
        .and_return(gcloud_double)
    end

    let(:config) {%[
      type           gcloud_storage

      key            test_key.json
      project        test_project
      bucket         test_bucket
      path           /path/%Y-%m-%d-%H-${chunk_id}

      utc
      buffer_type    memory
    ]}
    let(:driver) { create_driver(config) }
    subject { driver.instance }

    specify { expect(subject).to be_a TimeSlicedOutput }

    describe '#configure' do
      it('sets the key file path') { expect(subject.key).to eq 'test_key.json' }
      it('sets the project_id') { expect(subject.project).to eq 'test_project' }
      it('sets the bucket_id') { expect(subject.bucket).to eq 'test_bucket' }
      it('sets the path') { expect(subject.path).to eq '/path/%Y-%m-%d-%H-${chunk_id}' }
      it('sets the time_slice_format') { expect(subject.time_slice_format).to eq '%Y%m%d%H' }

      it('sets the formatter') do
        expect(subject.instance_variable_get(:@formatter))
          .to be_a(TextFormatter::OutFileFormatter)
      end

      %w[project bucket key].each do |param|
        context "when '#{param}' is missing" do
          let(:wrong_config) { config.sub(/^\s*#{param}.+$/, '') }

          specify do
            expect { create_driver(wrong_config) }
              .to raise_error(ConfigError)
          end
        end
      end

      context "when path does not include '${chunk_id}'" do
        let(:wrong_config) { config.sub('${chunk_id}', '') }

        specify do
          expect { create_driver(wrong_config) }
            .to raise_error(ConfigError)
        end
      end
    end

    describe '#start' do
      it 'sets up the Google Cloud bucket' do
        stub_gcloud

        expect { subject.start }
          .to change { subject.instance_variable_get(:@gs_bucket) }
          .from(nil).to(:dummy_bucket)
      end
    end

    describe '#write' do
      it 'writes the received chunk' do
        stub_gcloud

        time = Time.parse("2015-10-19 13:14:15 UTC").to_i
        driver.emit({"a"=>1}, time)
        driver.emit({"a"=>2}, time)

        # GcloudStorageOutput#write returns chunk.read
        expect(driver.run.first)
          .to eq(
            %[2015-10-19T13:14:15Z\ttest\t{"a":1}\n] +
            %[2015-10-19T13:14:15Z\ttest\t{"a":2}\n]
        )
      end
    end
  end
end
