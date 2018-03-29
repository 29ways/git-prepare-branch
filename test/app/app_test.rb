require 'test_helper'

require 'app'

describe App do
  describe '.configure' do
    it 'should create a new application instance based on the configuration' do
      app = App.configure do
        title 'My application'
      end

      assert_equal 'My application', app.title
    end
  end
end