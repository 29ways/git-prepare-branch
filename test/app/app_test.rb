require 'test_helper'

require 'app'

describe App do
  subject { App.new }

  describe 'event handling' do
    it 'should accept handlers to be triggered' do
      handled = nil

      subject.add_event_handler(:some_event) { handled = true }
      assert_nil handled

      subject.trigger :different_event
      assert_nil handled

      subject.trigger :some_event
      assert handled
    end

    it 'should accept multiple handlers per event' do
      handled = nil
      handled2 = nil

      subject.add_event_handler(:some_event) { handled = true }
      subject.add_event_handler(:some_event) { handled2 = true }

      subject.trigger :some_event

      assert handled
      assert handled2
    end
  end

  describe '#add_variable' do
    it 'should add the variable to the context' do
      subject.add_variable :some_var, value: 'some-val'
      assert_equal 'some-val', subject.context.variables.some_var
    end

    it 'should override existing variables' do
      subject.add_variable :some_var, value: 'some-val'
      assert_equal 'some-val', subject.context.variables.some_var

      subject.add_variable :some_var, value: 'other-val'
      assert_equal 'other-val', subject.context.variables.some_var
    end

    describe 'when the capture argument is set' do
      it 'should use the terminal to capture the variable' do
        subject.add_variable :some_var, capture: 'echo capture_this'
        assert_equal 'capture_this', subject.context.variables.some_var
      end
    end
  end

  describe '#configure' do
    it 'configure application instance' do
      subject.configure do
        title 'My application'
      end

      assert_equal 'My application', subject.title
    end
  end

  describe '#context' do
    it 'should contain any initialised variables' do
      subject.add_variable :some_var, capture: 'echo someval'
      assert_equal 'someval', subject.context.variables.some_var
    end
  end
end