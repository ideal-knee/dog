module Dog
  class Command
    attr_reader :title

    def initialize(title)
      @title = title
      @matchers = []
      @subcommands = []
      @action = ->(input){ }
    end

    def action(&action)
      @action = action
    end

    def matches(*matchers)
      @matchers += matchers
    end

    def matches?(input_string)
      @matchers.any? do |matcher|
        if matcher.is_a?(String)
          input_string.match(/(\s|^)#{matcher}(\s|$)/)
        else
          input_string.match(matcher)
        end
      end
    end

    def subcommand(title, &block)
      subcommand = Command.new title
      subcommand.instance_eval &block
      @subcommands << subcommand
    end

    def subcommand_response(input_string)
      @subcommands.each do |subcommand|
        response = subcommand.respond_to(input_string)
        return response unless response.nil?
      end

      nil
    end

    def respond_to(input_string)
      if matches?(input_string)
        response = subcommand_response input_string
        response || @action.call(input_string)
      end
    end
  end
end
