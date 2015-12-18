require 'logger'
require 'yaml'

class PulseLogger < Logger
  CONFIG_LOAD_INTERVAL=60
  attr_accessor :log_config_filename, :last_loaded

  def initialize(identifier = nil)
    super(STDOUT)
    @progname = identifier unless identifier.nil?
    @log_config_filename = ENV['PULSE_LOGGER_CONFIG'] || ''
    @last_loaded = Time.at(0)
  end

  def load_log_config
    return unless File.exist?(@log_config_filename)
    return unless Time.now - @last_loaded > CONFIG_LOAD_INTERVAL
    config = load_config_from_file
    self.level = ::Logger.const_get(config['level'])
  end

  # Override default logging method to check log configuration
  # on a timer
  def add(severity, message = nil, progname = nil, &block)
    load_log_config
    super
  end

  private

  def load_config_from_file
    YAML.load_file(@log_config_filename)
    @last_loaded = Time.now
  end
end
