module Canson
  module DSL
    def inherited(subclass)
      generate_proto_based_files
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

    private

    def generate_proto_based_files
      puts '~~~~~~~~~~~~'
      puts 'inherited'
      puts '~~~~~~~~~~~~'
    end
  end
end
