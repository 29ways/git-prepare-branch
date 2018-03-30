# frozen_string_literal: true

class Configurator
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def apply(&block)
    instance_exec(&block)
  end

  def on(event, &block)
    app.add_event_handler event, &block
  end

  def routing(routes)
    @app.router = routes
  end

  def screen(name, &block)
    app.add_screen ScreenDSL.new(Screen.new(name)).apply(&block).screen
  end

  def title(value)
    app.title = value
  end

  def variable(name, capture: nil, value: nil)
    app.add_variable name, capture: capture, value: value
  end

  class ScreenDSL
    attr_reader :screen

    def initialize(screen)
      @screen = screen
    end

    def apply(&block)
      self.tap do |s|
        instance_exec(&block)
      end
    end

    def command(*args)
      screen.add_command(*args)
    end

    def description(value)
      screen.description = value
    end

    def display(command)
      screen.display = command
    end

    def heading(message, options={})
      screen.heading = message
      screen.heading_style = options[:style]
    end

    def title(value)
      screen.title = value
    end
  end
end
