require 'giternal'

module Giternal
  module Error
    # Exceptions that should be captured and produce user-visible messaging
    # should inherit from ReportableError
    class ReportableError < StandardError; end

    class UnknownCommand < ReportableError; end
  end
end
