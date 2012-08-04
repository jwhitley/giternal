require 'giternal'

require 'log4r'

module Giternal
  def self.logger
    return @logger if @logger

    @logger = (Log4r::Logger['giternal'] || Log4r::Logger.new('giternal'))
    @logger.level = Log4r::WARN
    @logger.outputters = Log4r::Outputter.stdout
    @logger
  end

  def self.silence_logging
    # Log4r Null logger idiom from http://log4r.rubyforge.org/manual.html#nullobj
    @logger = Log4r::Logger.root
  end
end
