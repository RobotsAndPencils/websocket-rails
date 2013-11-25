require 'spec_helper'

module WebsocketRails
  
  class MockWebSocket
    def self.websocket?(env)
      true
    end

    def protocol
      ''
    end

    attr_writer :onopen, :onmessage, :onerror, :onclose

    def env
      @env ||= Rack::MockRequest.env_for('/websocket')
    end

    def onopen(event = nil)
      @onopen.call(event)
    end

    def onmessage(event=nil)
      @onmessage.call(event)
    end

    def onerror(event=nil)
      @onerror.call(event)
    end

    def onclose(event=nil)
      @onclose.call(event)
    end

    def rack_response
      [ -1, {}, [] ]
    end

    def send(*args)
      true
    end

    def trigger(event)
      true
    end

    def id
      object_id.to_i
    end
  end

end
