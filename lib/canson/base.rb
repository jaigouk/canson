# frozen_string_literal: true

require 'rack/utils'
require 'rack/media_type'
require 'json'

module Canson
  # used to create a new app
  # App < CansonBase
  #   get '/foo' do
  #     {result: 'ok'}
  #   end
  # end
  class Base
    extend Forwardable
    include Mustermann

    attr_reader :klass
    attr_accessor :responder

    def_delegators :@klass, :routes, :method_missing

    class << self
      def inherited(subclass)
        subclass.routes @routes
      end

      [:on_open, :on_close, :on_shutdown, :on_message].each do |m|
        define_method m do |&block|
          @responder = Responder.new :ws, &block
          routes[m]['websocket_method'] = @responder
          @responder.call
        end
      end

      [:get, :post, :put, :delete, :options].each do |m|
        define_method m do |path, opts = {}, &block|
          path = ::Mustermann.new path, opts
          @responder = Responder.new m, &block
          routes[m][path.to_s] = @responder
          @responder.call
        end
      end

      def routes(r = nil)
        return @routes = r if r
        @routes ||= Hash.new { |h, k| h[k] = RouteMap.new }
      end
    end

    def initialize(responder = Responder.new)
      @responder = responder
      @klass = self.class
      @websocket = nil
    end

    def call(env)
      m = env['REQUEST_METHOD'].tr('/', '').downcase.to_sym
      target = routes[m][env['PATH_INFO']]

      if m == :get && env['PATH_INFO'] == '/' && env['HTTP_UPGRADE'] != 'websocket'
        out = File.open File.expand_path('./index.html')
        return [200, { 'X-Sendfile' => File.expand_path('./index.html'), 'Content-Length' => out.size }, out]
      end

      return handle_socket(env) if env['HTTP_UPGRADE'] == 'websocket'
      return  [404, {}, ['no route']] unless target
      return call_result(env, target)
    rescue => e
      puts e.message
      [500, {}, ["server error #{e.message}".to_json]]
    end

    def handle_socket(env)
# require 'byebug'
# byebug
      nickname = env['PATH_INFO'][1..-1].force_encoding 'UTF-8'
      # env['upgrade.websocket'.freeze] = 'websocket'
      # on_message = routes[:on_message]
      # proc = Proc.new{|env| puts env}
      # proc.call(env)
      # routes[:on_message][nickname] = Responder.new(:ws, proc)

      # self.class.instance_exec(env, &(routes[:on_message][nickname].call))
      # if env.class == String
        # self.class.instance_exec(env, &(on_message.call))
      # else
      #   nickname = env['PATH_INFO'][1..-1].force_encoding 'UTF-8'
      #   env['upgrade.websocket'.freeze] = routes[:ws][:on_message][nickname]
      # end

      if env['HTTP_UPGRADE'.freeze] =~ /websocket/i
        routes[:on_message][nickname] ||= Canson::Websocket.new(env)
        routes[:on_message][nickname].on_open = routes[:on_open]['websocket_method']
        routes[:on_message][nickname].on_close = routes[:on_close]['websocket_method']
        routes[:on_message][nickname].on_shutdown = routes[:on_shutdown]['websocket_method']
        routes[:on_message][nickname].on_message = routes[:on_message]['websocket_method']
        env['upgrade.websocket'.freeze] = routes[:on_message][nickname]
        return [0, {}, []]
      end
    end

    private

    def call_result(env, target)
      param = get_param(env)
      result = if param.nil?
                 self.class.instance_exec(&(target.call))
               else
                 self.class.instance_exec(param, &(target.call))
               end
      return [404, {}, ['not found']] if result.values.include? nil
      [200, { 'Content-Type' => 'application/json' }, [result.to_json]]
    end

    def get_param(env)
      req = Rack::Request.new(env)
      param = req.params.empty? ? req.body.read : req.params
      return if param.empty?
      param_to_hash(param)
    end

    def param_to_hash(param)
      if param.class == Hash
        if param.keys.first.include?(':')
          return to_hash(JSON.parse(param.keys.first))
        end
        to_hash(param)
      else
        to_hash(JSON.parse(param))
      end
    end

    def to_hash(ele)
      ele.map { |k, v| [k.to_sym, v] }.to_h
    end
  end
end
