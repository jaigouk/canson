# frozen_string_literal: true

module Canson
  # keeps routes and responders
  class RouteMap
    def initialize
      @hash = {}
    end

    def []=(route, responder)
      @hash[route] = responder
    end

    def [](route)
      _path, responder = @hash.find { |k, _v| k.match(route) }
      responder
    end
  end
end
