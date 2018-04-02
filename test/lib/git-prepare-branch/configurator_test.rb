require 'test_helper'

require 'git-prepare-branch/app'
require 'git-prepare-branch/configurator'

module GitPrepareBranch
  describe Configurator do
    subject { Configurator.new(app) }

    let(:app) { App.new }

    describe '#apply' do
      it 'should create a new application instance based on the configuration' do
        subject.apply do
          title 'My application'
        end

        assert_equal 'My application', app.title
      end
    end

    describe '#on' do
      it 'should add an event handler to the app' do
        handled = nil

        subject.on :some_event do
          handled = true
        end

        app.trigger :some_event
        assert handled
      end
    end

    describe '#routing' do
      it 'should define a routing function for the app' do
        subject.screen(:some_screen) {}
        subject.routing -> (context) {
          :some_screen
        }

        assert_equal :some_screen, app.current_screen.name
      end
    end

    describe '#screen' do
      it 'should create a new screen using the screen DSL' do
        subject.screen :some_screen do
          title 'Some screen'
          description 'This is a screen'
        end

        assert_equal 'Some screen', app.screens[:some_screen].title
        assert_equal 'This is a screen', app.screens[:some_screen].description
      end
    end

    describe '#title' do
      it 'should set the title of the application' do
        subject.title 'My application'
        assert_equal 'My application', app.title
      end
    end

    describe '#variable' do
      it 'should add a variable to the application' do
        subject.variable :some_var, capture: 'echo "some command"'
        assert_equal app.context.variables[:some_var], 'some command'
      end
    end
  end
end