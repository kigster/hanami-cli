require 'spec_helper'

RSpec.describe 'Usage and an exit code' do
  let(:command_prefix) { '' }
  let(:argv) { '' }
  let(:command_line) { "#{command_prefix}foo #{argv}" }
  let(:command_prefix) { 'PRINT_UNKNOWN_COMMANDS=true ' }

  subject(:executioner) { CommandRunner.new(command_line, run_now: true) }

  # This shared example can be customized with an expected output, exit code and an exception
  shared_examples_for :a_command_that_ran_with do |expected_output: FOOS_COMPLETE_OUTPUT, expected_code: 0, expected_error: nil|
    it 'its output should match the expected output' do
      expect(subject.out).to eq(expected_output)
    end

    it "its exit code should be #{expected_code}" do
      expect(subject.code).to eq(expected_code)
    end

    if expected_error.nil?
      it 'should not produce an error' do
        expect(subject.error).to be_nil
      end
    else
      it 'should produce an error' do
        expect(subject.error).to eq(expected_error)
      end
    end
  end

  describe 'for a valid command' do
    describe 'with a non-existent subcommand' do
      let(:argv) { 'moo' }
      it_behaves_like :a_command_that_ran_with,
                      expected_output: "Error:\n  Unknown command(s): moo\n\n#{FOOS_COMPLETE_OUTPUT}",
                      expected_code: 1
    end

    describe 'with no subcommands but -h or --help options' do
      let(:argv) { '-h' }
      it_behaves_like :a_command_that_ran_with
    end

    describe 'with no arguments at all' do
      let(:command_prefix) { '' }
      let(:argv) { '' }
      it_behaves_like :a_command_that_ran_with
    end

    describe 'given a command that expects a subcommand' do
      describe 'given --help' do
        let(:argv) { 'assets --help' }
        it_behaves_like :a_command_that_ran_with,
                        expected_output: "Commands:\n  foo assets precompile            # Precompile assets for deployment\n",
                        expected_error: nil,
                        expected_code: 0
      end

      describe 'given valid subcommand' do
        let(:argv) { 'assets precompile' }
        it_behaves_like :a_command_that_ran_with,
                        expected_output: '',
                        expected_error: nil,
                        expected_code: 0
      end

      describe 'given an invalid subcommand' do
        let(:argv) { 'assets purge' }
        it_behaves_like :a_command_that_ran_with,
                        expected_output: "Error:\n  Unknown command(s): purge\n\nCommands:\n  foo assets precompile            # Precompile assets for deployment\n",
                        expected_error: nil,
                        expected_code: 1
      end
    end
  end

  describe 'for a totally invalid or non-existent command' do
    let(:command_line) { '/bin/bash -c hello 2>&1' }
    it_behaves_like :a_command_that_ran_with,
                    expected_output: "/bin/bash: hello: command not found\n",
                    expected_code: 127
  end
end
