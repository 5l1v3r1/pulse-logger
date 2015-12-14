require 'syslog'

class PulseLogger
  # This constant contains the lookup information necessary to identify and
  # select the appropriate log level. The order is important and defined in
  # RFC5424.
  #
  # * Emergency: A 'panic' condition usually affecting multiple services.
  #   This should be an immediate 'all-hands on deck' level of message.
  #   'System is unusable'.
  # * Alert: Should be corrected immediately. 'Action must be taken
  #   immediately'
  # * Critical: Should be corrected immediately, but indicates a failure in
  #   a _secondary_ system. Everything should be able to continue operating
  #   at a degraded state with this level of message.
  # * Error: Non-urgent failures, these should be relayed to both
  #   developers and admins.
  # * Warning: Not an error, but an indication that an error may occur if
  #   action is not taken.
  # * Notice: A normal but significant condition. Login failures would fall
  #   into this. If events are useful to be summarized in an email to both
  #   admins and developers to spot potential problems, the message belongs
  #   in this category or more severe.
  # * Informational: Normal operating messages, may be harvested for
  #   reporting, measuring  throughput, etc.
  # * Debug: Information that is useful only to developers and would
  #   otherwise be considered noise in the log files.
  EMERG = Syslog::LOG_EMERG
  ALERT = Syslog::LOG_ALERT
  CRIT = Syslog::LOG_CRIT
  ERROR = Syslog::LOG_ERR
  WARN = Syslog::LOG_WARNING
  NOTICE = Syslog::LOG_NOTICE
  INFO = Syslog::LOG_INFO
  DEBUG = Syslog::LOG_DEBUG

  LABEL = %w( EMERG ALERT CRIT ERROR WARN NOTICE INFO DEBUG )

  # Program name that will be included with log messages.
  attr_accessor :progname

  # A syntactically neat way to log alerts.
  #
  # @param [String] message
  def alert(message, &blk)
    log(ALERT, message, &blk)
  end

  # A syntactically neat way to log critical messages.
  #
  # @param [String] message
  def crit(message, &blk)
    log(CRIT, message, &blk)
  end

  # A syntactically neat way to log debug messages.
  #
  # @param [String] message
  def debug(message, &blk)
    log(DEBUG, message, &blk)
  end

  # A syntactically neat way to log emergency messages.
  #
  # @param [String] message
  def emerg(message, &blk)
    log(EMERG, message, &blk)
  end

  alias_method :fatal, :emerg

  # A syntactically neat way to log errors.
  #
  # @param [String] message
  def error(message, &blk)
    log(ERROR, message, &blk)
  end

  # A syntactically neat way to log informational messages.
  #
  # @param [String] message
  def info(message, &blk)
    log(INFO, message, &blk)
  end

  # Create an instance of the log class.
  #
  # @param [String,IO,Object#write] log_device A filename (String), IO object
  #   (typically STDOUT or STDERR), an open file, or any other object that
  #   responds to both #write and #close.
  # @param [String,Symbol,Fixnum] log_level A log-level setting. Strings and
  # symbols are supported and case-insensitive. Fixnums should correspond to
  # the PulseLogger::DEBUG..EMERG constants.
  def initialize(identifier, log_level=nil)
    @progname = identifier || "#{File.basename($0)}"
    self.open_log_device(@progname)
    self.severity = self.parse_log_level(log_level)
  end

  # Open the log device
  #
  # @param [String] identifier The application identifier for syslog tagging.
  def open_log_device(identifier)
    @log_device = Syslog.open(identifier, Syslog::LOG_PID, Syslog::LOG_DAEMON)
  end

  # Parse log level from a String, Symbol, or Fixnum.
  #
  # @param [String,Symbol,Fixnum] log_level A log-level setting. Strings and
  # symbols are supported and case-insensitive. Fixnums are returned directly.
  def parse_log_level(log_level)
    case log_level
      when NilClass
        return INFO
      when Fixnum
        return log_level
      when Symbol
        return LABEL.index(log_level.to_s.upcase) || INFO
      when String
        return LABEL.index(log_level.upcase) || INFO
      else
        return INFO
    end
  end

  # Log a message is the configured severity is high enough. Generally it
  # will be easier for users to make use of the various syntactic methods
  # (#info, #debug, #warning, etc) over this to log their messages.
  #
  # @param [Symbol] sev Severity of the message
  # @param [String] message The message to log
  # @return [Boolean]
  def log(sev, message=nil, &blk)
    sev ||= DEBUG
    if @log_device.nil? or sev > @severity
      return true
    end
    if message.nil?
      if block_given?
        message = yield
      else
        return true
      end
    end
    @log_device.log(sev, "#{LABEL[sev]}: #{message}")
    true
  end

  # A syntactically neat way to log notices.
  #
  # @param [String] message
  def notice(message, &blk)
    log(NOTICE, message, &blk)
  end

  # Set the severity of this logger. Any messages more verbose that what is
  # currently set will be quietly ignored.
  #
  # @param [Fixnum] sev see Pulse::PulseLogger::SEVERITIES
  def severity=(sev)
    @severity = sev
  end

  # Provided for compatibility with core Logger interface
  def level
    self.severity
  end

  # Provided for compatibility with core Logger interface
  def level=(log_level)
    self.severity = self.parse_log_level(log_level)
  end

  # A syntactically neat way to log warnings.
  #
  # @param [String] message
  def warning(message, &blk)
    log(WARN, message)
  end

  alias_method :warn, :warning

  # The following methods return true if logging at or above a
  # given severity (required for ActiveRecord)
  def debug?
    @severity >= DEBUG
  end

  def info?
    @severity >= INFO
  end

  def warn?
    @severity >= WARN
  end

  def error?
    @severity >= ERROR
  end

  def fatal?
    @severity >= EMERG
  end
end


