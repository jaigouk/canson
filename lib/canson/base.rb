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
      return  [404, {}, ['no route']] unless target
      return call_result(env, target)
    rescue => e
      [500, {}, ["server error #{e.message}".to_json]]
    end

    private

    def call_result(env, target)
      param = get_param(env)
      result = if param.nil?
                 target.call.call
               else
                 target.call.call(param)
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
