# frozen_string_literal: true

require 'test_helper'

require 'screen'

describe Screen do
  subject { Screen.new(:some_screen) }

  describe '#add_command' do
    it 'should add a new command to the screen' do
      subject.add_command 's', :some_command, 'echo 1'
      assert_equal 'echo 1', subject.commands['s'].command
    end
  end
end
