# frozen_string_literal: true

require 'rack/utils'
require 'rack/media_type'
require 'json'

module Canson
  DEFAULT_PROTO_DIR = 'proto'.freeze
  DEFAULT_PUBLIC_DIR = 'public'.freeze
  DEFAULT_SERVICES_DIR = 'services'.freeze
  DEFAULT_FILE = 'index.html'.freeze

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

    def_delegators :@klass, :routes, :method_missing, :filename, :services_dir,
                   :public_dir, :proto_dir, :root

    class << self
      attr_accessor :app_file

      def inherited(subclass)
        subclass.app_file = caller_locations.map(&:absolute_path).find do |f|
          !f.start_with?(File.dirname(__FILE__) + File::SEPARATOR)
        end
        subclass.proto_dir DEFAULT_PROTO_DIR
        subclass.services_dir DEFAULT_SERVICES_DIR
        subclass.public_dir DEFAULT_PUBLIC_DIR
        subclass.filename DEFAULT_FILE
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

      def root
        @root ||= File.expand_path '..', app_file
      end

      def proto_dir(d = nil)
        @proto_dir = d if d
        File.join root, @proto_dir
      end

      def services_dir(d = nil)
        @services_dir = d if d
        File.join root, @services_dir
      end

      def public_dir(d = nil)
        @public_dir = d if d
        File.join root, @public_dir
      end

      def filename(d = nil)
        @filename = d if d
        File.join(root, @filename)
      end

      def routes(r = nil)
        return @routes = r if r
        @routes ||= Hash.new { |h, k| h[k] = RouteMap.new }
        @routes
      end
    end

    def initialize(responder = Responder.new)
      @responder = responder
      @klass = self.class
      @websocket = nil
      @filename = 'index.html'
      @proto_dir = DEFAULT_PROTO_DIR
      @services_dir = DEFAULT_SERVICES_DIR
      @public_dir = DEFAULT_PUBLIC_DIR
      @filename = DEFAULT_FILE
    end

    def call(env)
      m = env['REQUEST_METHOD'].tr('/', '').downcase.to_sym
      target = routes[m][env['PATH_INFO']]
      return send_default_file if requesting_default_file?(m, env)
      return handle_socket(env) if env['HTTP_UPGRADE'] == 'websocket'
      return [404, {}, ['no route']] unless target
      call_result(env, target)
    rescue => e
      puts e.message
      [500, {}, ["server error #{e.message}".to_json]]
    end

    def handle_socket(env)
      nickname = env['PATH_INFO'][1..-1].force_encoding 'UTF-8'
      return unless env['HTTP_UPGRADE'.freeze] =~ /websocket/i
      ws = routes[:on_message][nickname] ||= Canson::Websocket.new(env)
      assign_ws_calls(ws)
      env['upgrade.websocket'.freeze] = ws
      [0, {}, []]
    end

    private

    def send_default_file
      out = File.open(file)
      [200, { 'X-Sendfile' => file,
              'Content-Type' => 'text/html',
              'Content-Length' => out.size }, out]
    end

    def requesting_default_file?(m, env)
      m == :get && env['PATH_INFO'] == '/' && File.file?(file)
    end

    def file
      File.join(public_dir, @filename)
    end

    def nickname(env)
      env['PATH_INFO'][1..-1].force_encoding 'UTF-8'
    end

    def assign_ws_calls(ws)
      ws.on_open = routes[:on_open]['websocket_method']
      ws.on_close = routes[:on_close]['websocket_method']
      ws.on_shutdown = routes[:on_shutdown]['websocket_method']
      ws.on_message = routes[:on_message]['websocket_method']
    end

    def call_result(env, target)
      param = get_param(env)
      result = if param.nil?
                 self.class.instance_exec(&target.call)
               else
                 self.class.instance_exec(param, &target.call)
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
