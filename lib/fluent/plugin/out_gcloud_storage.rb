module Fluent
  class GcloudStorageOutput < TimeSlicedOutput
    CHUNK_ID_PLACE_HOLDER = '${chunk_id}'
    DEFAULT_TIME_SLICE_FORMAT = '%Y%m%d'
    UPLOAD_CHUNK_SIZE = 5 * 1024 * 1024

    Fluent::Plugin.register_output('gcloud_storage', self)

    config_set_default :time_slice_format, DEFAULT_TIME_SLICE_FORMAT
    config_param :project, :string, :default => nil
    config_param :bucket,  :string, :default => nil
    config_param :key,     :string, :default => nil
    config_param :path,    :string, :default => nil
    config_param :format,  :string, :default => 'out_file'

    def initialize
      super

      require 'gcloud'
    end

    def configure(conf)
      predict_time_slice_format!(conf)

      super

      ensure_gcloud_arguments!
      ensure_proper_path!
      setup_formatter(conf)
    end

    def start
      super

      @gs_bucket = Gcloud
        .new(@project, @key)
        .storage
        .bucket(@bucket)
    end

    # def shutdown; super; end

    def format(tag, time, record)
      @formatter.format(tag, time, record)
    end

    def write(chunk)
      @gs_bucket.create_file(
        chunk.path,
        generate_path(chunk),
        chunk_size: UPLOAD_CHUNK_SIZE
      )
    end

    private

    def generate_path(chunk)
      path_chunk_id = Base64.encode64(chunk.unique_id)

      Time
        .strptime(chunk.key, @time_slice_format) # parse chunk time
        .strftime(@path)                         # replace path placeholders
        .gsub(CHUNK_ID_PLACE_HOLDER, path_chunk_id)
    end

    def predict_time_slice_format!(conf)
      return unless (path = conf['path'])

      conf['time_slice_format'] =
        case
        when path.index('%S') then '%Y%m%d%H%M%S'
        when path.index('%M') then '%Y%m%d%H%M'
        when path.index('%H') then '%Y%m%d%H'
        else DEFAULT_TIME_SLICE_FORMAT
        end
    end

    def ensure_gcloud_arguments!
      fail ConfigError, "'project' must be specified." unless @project
      fail ConfigError, "'bucket' must be specified." unless @bucket
      fail ConfigError, "'key' must be specified." unless @key
    end

    def ensure_proper_path!
      fail ConfigError, "'path' parameter is required" unless @path

      if @path.index(CHUNK_ID_PLACE_HOLDER).nil?
        fail Fluent::ConfigError,
          'path must contain ${chunk_id}, which is the placeholder for buffer'\
          'chunk.key. Google Cloud Storage does not support append operation'\
          'on objects. Tip: Use gsutil compose command to merge objects.'
      end
    end

    def setup_formatter(conf)
      # http://docs.fluentd.org/articles/out_file#format
      @formatter = Plugin.new_formatter(@format)
      @formatter.configure(conf)
    end
  end
end

