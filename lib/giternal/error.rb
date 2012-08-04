require 'giternal'

module Giternal
  module Error
    # Exceptions that should be captured and produce user-visible messaging
    # should inherit from ReportableError
    class ReportableError < StandardError
      def format
        message
      end
    end

    # ReportableErrors that should also show command usage
    class UsageError < ReportableError; end

    # Reportable and Usage Errors
    #
    class NotGitRepo < ReportableError
      def format
        "Directory '#{message}' exists but is not a git repository"
      end
    end

    class UnknownCommand < UsageError
      def format
        "Unknown command: '#{message}'"
      end
    end

    # Non-reportable errors
    #
    # These must be caught or else they're real and pertinent problems
    #
    class NotCheckedOut < StandardError
      def format
        "Repository '#{message}' is not checked out"
      end
    end
  end
end
