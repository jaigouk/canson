require 'spec_helper'

describe Canson::Base do
  def app
    TestApp.new
  end

  before(:all) do
    @base = Canson::Base.new()
  end

  describe 'filename' do
    it 'sets filename that loads default html' do
      @base.filename('base.html')
      @base.filename.must_match 'base.html'
    end
  end

  describe 'public_dir' do
    it 'sets public_dir that loads default html' do
      @base.public_dir('www')
      @base.public_dir.must_match 'www'
    end
  end

  describe 'proto_dir' do
    it 'sets proto_dir that loads default html' do
      @base.proto_dir('protos')
      @base.proto_dir.must_match 'protos'
    end
  end

  describe 'services_dir' do
    it 'sets services_dir that loads default html' do
      @base.services_dir('micro_service')
      @base.services_dir.must_match 'micro_service'
    end
  end
end
