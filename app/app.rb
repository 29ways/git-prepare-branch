class App
  attr_accessor :title

  def configure(&block)
    Configurator.new(self).run(&block)
    self
  end

  class << self
    def configure(&block)
      self.new.configure(&block)
    end
  end

  class Configurator
    attr_reader :app

    def initialize(app)
      @app = app
    end

    def run(&block)
      instance_exec(&block)
    end

    def title value
      app.title = value
    end
  end
end