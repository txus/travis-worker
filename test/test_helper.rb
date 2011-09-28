ENV['RAILS_ENV'] ||= 'test'

require 'bundler/setup'

require 'test/unit'
require 'test_declarative'
require 'mocha'

require 'travis/worker'
require 'support/mock'

FIXTURES = {}
require 'fixtures/payloads'
require 'fixtures/vboxmanage'

class Test::Unit::TestCase
  attr_reader :shell

  def setup
    @shell = Travis::Worker.shell = Mock::Shell.new
    Mocha::Mockery.instance.verify
  end

  def expect_shell(commands)
    shell_commands = sequence('shell_commands')
    commands.each do |command|
      method  = :execute
      returns = true

      if command.is_a?(Hash)
        method  = command[:method]
        returns = command[:returns]
        command = command[:command]
      end

      shell.expects(method).in_sequence(shell_commands).with(command, anything).returns(returns).once
    end
  end

  def assert_stdout_equals(expected_stdout, &block)
    old_std_out = $stdout
    $stdout = StringIO.new

    yield block

    assert_equal expected_stdout, $stdout.string

    $stdout = old_std_out
  end
end

