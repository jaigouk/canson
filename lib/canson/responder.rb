# frozen_string_literal: true

module Canson
  # responsible to return the block
  class Responder
    attr_reader :method
    attr_writer :base

    def initialize(method = nil, &block)
      @method = method
      @response_handler = block
    end

    def call
      @response_handler
    end
  end
end
