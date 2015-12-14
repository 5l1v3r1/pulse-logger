require 'rspec'
require_relative '../lib/pulse_logger'

describe PulseLogger do
  before(:all) do
    @logger = PulseLogger.new('test-logger')
  end
  describe '#parse_log_level' do
    it 'accepts string arguments' do
      expect(@logger.parse_log_level('debug')).to equal(PulseLogger::DEBUG)
      expect(@logger.parse_log_level('Debug')).to equal(PulseLogger::DEBUG)
      expect(@logger.parse_log_level('DEBUG')).to equal(PulseLogger::DEBUG)
    end
    it 'accepts symbolic arguments' do
      expect(@logger.parse_log_level(:debug)).to equal(PulseLogger::DEBUG)
      expect(@logger.parse_log_level(:Debug)).to equal(PulseLogger::DEBUG)
      expect(@logger.parse_log_level(:DEBUG)).to equal(PulseLogger::DEBUG)
    end
    it 'passes Fixnum without modification' do
      expect(@logger.parse_log_level(PulseLogger::DEBUG)).to equal(PulseLogger::DEBUG)
    end
    it 'defaults to INFO if nil or invalid' do
      expect(@logger.parse_log_level(true)).to equal(PulseLogger::INFO)
      expect(@logger.parse_log_level(nil)).to equal(PulseLogger::INFO)
    end
  end
end