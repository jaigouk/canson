require 'spec_helper'

describe Canson::Responder do
  before(:all) do
    block = Proc.new do |params|
      name = params[:name]
      { name: name }
    end
    @res = Canson::Responder.new(:post, &block)
  end

  describe 'init' do
    it 'has a method' do
      @res.method.must_equal :post
    end
  end

  describe 'call' do
    it 'returns the block' do
      result = @res.call.call({name: 'black'})
      expected = {name: "black"}
      result.must_equal expected
    end
  end
end
