# pulse-logger

A syslog-logger for Pulse applications.

## Configuring pulse-logger
### Configuration file
`pulse-logger` requires the `PULSE_LOGGER_CONFIG` environment
variable to be defined. The logger will attempt to read a
YAML file from this location every 60 seconds and update the
logging configuration accordingly. If the file does not exist,
`pulse-logger` will not change its configuration.

#### Example
With `PULSE_LOGGER_CONFIG=/app/logger.yml` and `/app/logger.yml` contents:

    ---
    level: DEBUG

the log level will be set to `Logger::DEBUG`. Available values for the log
level are `DEBUG`, `INFO`, `WARN`, `ERROR`, `FATAL`.
