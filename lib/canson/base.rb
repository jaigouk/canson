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

    def_delegators :@klass, :routes

    class << self
      def inherited(subclass)
        subclass.routes @routes
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
    end

    def call(env)
      m = env['REQUEST_METHOD'].tr('/', '').downcase.to_sym
      target = routes[m][env['PATH_INFO']]
      return call_result(env, target) if target
      [404, {}, ['not found']]
    end

    private

    def get_req(env)
      Rack::Request.new(env)
    end

    def call_result(env, target)
      param = parse_body(get_req(env))
      result = if param.nil?
                 target.call.call.to_json
               else
                 target.call.call(param).to_json
               end
      [200, { 'Content-Type' => 'application/json' }, [result]]
    end

    def parse_body(req)
      param = req.params.map { |k, _v| k }.first
      return unless param
      JSON.parse(param)
          .map { |k, v| [k.to_sym, v] }.to_h
    end
  end
end
