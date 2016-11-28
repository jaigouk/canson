#!/usr/bin/env ruby
require "bundler/setup"
require "canson"

desc "Generate service files from Protocol Buffers"
namespace :grpc do
  task :generate_ruby_files do
    Dir.glob("#{root}/proto/*.proto") do |prt|
      sub_dir = prt.split('/').last.gsub('.proto','')
      mkdir_p "#{root}/services/#{sub_dir}"
      sh("#{bin_file}", "-I", "#{root}/proto",
          "--ruby_out=#{root}/services/#{sub_dir}", "--grpc_out=#{root}/services/#{sub_dir}", prt)
    end
  end
end
task :environment => :grpc

def root
  Dir.pwd
end

def spec
  Gem::Specification.find_by_name("grpc-tools")
end

def gem_root
  spec.gem_dir
end

def bin_file
  "#{gem_root}/bin/grpc_tools_ruby_protoc"
end
