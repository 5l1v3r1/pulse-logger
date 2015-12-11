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
  def alert(message)
    log(ALERT, message)
  end

  # A syntactically neat way to log critical messages.
  #
  # @param [String] message
  def crit(message)
    log(CRIT, message)
  end

  # A syntactically neat way to log debug messages.
  #
  # @param [String] message
  def debug(message)
    log(DEBUG, message)
  end

  # A syntactically neat way to log emergency messages.
  #
  # @param [String] message
  def emerg(message)
    log(EMERG, message)
  end

  alias_method :fatal, :emerg

  # A syntactically neat way to log errors.
  #
  # @param [String] message
  def error(message)
    log(ERROR, message)
  end

  # A syntactically neat way to log informational messages.
  #
  # @param [String] message
  def info(message)
    log(INFO, message)
  end

  # Create an instance of the log class.
  #
  # @param [String,IO,Object#write] log_device A filename (String), IO object
  #   (typically STDOUT or STDERR), an open file, or any other object that
  #   responds to both #write and #close.
  def initialize(identifier)
    @progname = identifier || "#{File.basename($0)}"
    @log_device = Syslog.open(identifier, Syslog::LOG_PID, Syslog::LOG_DAEMON)
    self.severity = INFO
    Signal.trap('USR1', toggle_severity)
  end

  # Change the log level from INFO to DEBUG or vice versa. Used by the signal
  # handler to enable real-time log level updates for troubleshooting.
  def toggle_severity
    if @severity == DEBUG
      self.severity = INFO
      log(INFO, 'Changed log level to INFO')
    else
      self.severity = DEBUG
      log(DEBUG, 'Changed log level to DEBUG')
    end
  end

  # Log a message is the configured severity is high enough. Generally it
  # will be easier for users to make use of the various syntactic methods
  # (#info, #debug, #warning, etc) over this to log their messages.
  #
  # @param [Symbol] sev Severity of the message
  # @param [String] message The message to log
  # @return [Boolean]
  def log(sev, message)
    return true if sev > @severity
    @log_device.log(sev, "#{LABEL[sev]}: #{message}")
    true
  end

  # A syntactically neat way to log notices.
  #
  # @param [String] message
  def notice(message)
    log(NOTICE, message)
  end

  # Set the severity of this logger. Any messages more verbose that what is
  # currently set will be quietly ignored.
  #
  # @param [Fixnum] sev see Pulse::PulseLogger::SEVERITIES
  def severity=(sev)
    Syslog.mask = Syslog::LOG_UPTO(sev)
    @severity = sev
  end

  # A syntactically neat way to log warnings.
  #
  # @param [String] message
  def warning(message)
    log(WARN, message)
  end

  def warn(*args)
    warning(*args)
  end

  # Returns true if logging at debug severity (required for ActiveRecord)
  def debug?
    @severity == DEBUG
  end
end


