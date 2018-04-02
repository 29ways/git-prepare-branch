require 'rainbow'

module GitPrepareBranch
  class Styles
    def initialize(styler: nil)
      @styler = styler || Rainbow.global.method(:wrap)
    end

    def apply(text, style = :default)
      return text if style == :default
      send(style, text)
    end

    def bold(text)
      style(text).bright
    end

    def footer(text)
      style(text).color(:dimgray)
    end

    def header(text)
      style(text).color(:white).bg(:darkslateblue)
    end

    def header_ok(text)
      style(text).color(:white).bg(:darkgreen)
    end

    def header_warning(text)
      style(text).color(:white).bg(:red)
    end

    def hint(text)
      style(text).color(:dimgray)
    end

    alias hr footer

    private

    attr_reader :styler

    def style(text)
      styler.call(text)
    end
  end
end