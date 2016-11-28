module Canson
  # used to call websocket
  class Websocket
    attr_writer :on_open, :on_close, :on_shutdown, :on_message
    def initialize(env)
      @nickname = env['PATH_INFO'][1..-1].force_encoding 'UTF-8'
      @on_open = nil
      @on_close = nil
      @on_shutdown = nil
      @on_message = nil
    end

    def on_open
      bl = @on_open.call
      @on_open.class.instance_exec(&bl)
    end

    def on_close
      @on_close.class.instance_exec({ count: count }, &@on_close.call)
    end

    def on_shutdown
      @on_shutdown.class.instance_exec(&@on_shutdown.call)
    end

    def on_message(data)
      @on_message.class.instance_exec(
        { data: data, ws: self, nickname: @nickname }, &@on_message.call
      )
    end
  end
end
