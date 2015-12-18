require 'rspec'
require_relative '../lib/pulse_logger'

describe PulseLogger do
  describe '#load_log_config' do
    it 'loads a log file if enough time has elapsed' do
      @logger = PulseLogger.new
      @logger.last_loaded = Time.now - 120
      allow(File).to receive(:exist?) {true}
      expect(@logger).to receive(:load_config_from_file) { {'level' => 'WARN'} }
      @logger.load_log_config
    end

    it 'does not load a log file if time has not elapsed' do
      @logger = PulseLogger.new
      @logger.last_loaded = Time.now + 120
      allow(File).to receive(:exist?) {true}
      expect(@logger).not_to receive(:load_config_from_file)
      @logger.load_log_config
    end

    it 'does not load a log file if a file does not exist' do
      @logger = PulseLogger.new
      @logger.last_loaded = Time.now - 120
      allow(File).to receive(:exist?) {false}
      expect(@logger).not_to receive(:load_config_from_file)
      @logger.load_log_config
    end

    it 'sets the log level correctly' do
      @logger = PulseLogger.new
      @logger.last_loaded = Time.now - 120
      allow(File).to receive(:exist?) {true}
      allow(@logger).to receive(:load_config_from_file) { {'level' => 'WARN'} }
      @logger.load_log_config
      expect(@logger.level).to eq(::Logger::WARN)
    end
  end

  describe '#add' do
    it 'attempts to load a log configuration before printing a message' do
      @logger = PulseLogger.new
      @logger.last_loaded = Time.now - 120
      allow(File).to receive(:exist?) {true}
      @logger.level = ::Logger::INFO
      expect(@logger).to receive(:load_config_from_file).twice { {'level' => 'WARN'} }

      executed = false
      @logger.info {executed = true} # Block should not be executed if log level is warn
      expect(executed).to be_falsey
      @logger.warn {executed = true} # Block should be executed if log level is warn
      expect(executed).to be_truthy
    end
  end
end