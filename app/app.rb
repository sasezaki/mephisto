module Mephisto
  class App < Padrino::Application
    register LessInitializer
    register Padrino::Rendering
    register Padrino::Mailer
    register Padrino::Helpers

    enable :sessions

    ##
    # Caching support
    #
    # register Padrino::Cache
    # enable :caching
    #
    # You can customize caching store engines:
    #
    # set :cache, Padrino::Cache::Store::Memcache.new(::Memcached.new('127.0.0.1:11211', :exception_retry_limit => 1))
    # set :cache, Padrino::Cache::Store::Memcache.new(::Dalli::Client.new('127.0.0.1:11211', :exception_retry_limit => 1))
    # set :cache, Padrino::Cache::Store::Redis.new(::Redis.new(:host => '127.0.0.1', :port => 6379, :db => 0))
    # set :cache, Padrino::Cache::Store::Memory.new(50)
    # set :cache, Padrino::Cache::Store::File.new(Padrino.root('tmp', app_name.to_s, 'cache')) # default choice
    #

    ##
    # Application configuration options
    #
    # set :raise_errors, true       # Raise exceptions (will stop application) (default for test)
    # set :dump_errors, true        # Exception backtraces are written to STDERR (default for production/development)
    # set :show_exceptions, true    # Shows a stack trace in browser (default for development)
    # set :logging, true            # Logging in STDOUT for development and file for production (default only for development)
    # set :public_folder, 'foo/bar' # Location for static assets (default root/public)
    # set :reload, false            # Reload application files (default in development)
    # set :default_builder, 'foo'   # Set a custom form builder (default 'StandardFormBuilder')
    # set :locale_path, 'bar'       # Set path for I18n translations (default your_app/locales)
    # disable :sessions             # Disabled sessions by default (enable if needed)
    # disable :flash                # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
    # layout  :my_layout            # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
    #

    ##
    # You can configure for a specified environment like:
    #
    #   configure :development do
    #     set :foo, :bar
    #     disable :asset_stamp # no asset timestamping for dev
    #   end
    #

    ##
    # You can manage errors like:
    #
    #   error 404 do
    #     render 'errors/404'
    #   end
    #
    #   error 505 do
    #     render 'errors/505'
    #   end

    before %r{^/charts|^/$} do
      @services = ChartGroup.services

      if params[:service_name]
        @service_name = params[:service_name]
        @sections = ChartGroup.sections(service_name: params[:service_name])

        if params[:section_name]
          @section_name = params[:section_name]
          @chart_groups = ChartGroup.all(
            service_name: @service_name,
            section_name: @section_name,
            order: 'name',
          )

          if params[:chart_group_name]
            @chart_group_name = params[:chart_group_name]
            @chart_group      = ChartGroup.first(
              service_name: @service_name,
              section_name: @section_name,
              name: @chart_group_name,
            )
            @charts = Chart.all(
              chart_group_id: @chart_group.id,
              order: 'name',
            )


            if params[:chart_name]
              @chart_name = params[:chart_name]
              @chart      = Chart.first(
                chart_group_id: @chart_group.id,
                name: @chart_name,
              )
            end
          end
        end
      end
    end

    get :charts, :with => [:service_name, :section_name, :chart_group_name, :chart_name] do
      @stats = Stat.all(
        chart_id: @chart.id,
        order: 'label',
      )

      render :chart
    end

    get :charts, :with => [:service_name, :section_name, :chart_group_name] do
      render :chart
    end

    get :charts, :with => [:service_name, :section_name] do
      render :section
    end

    get :charts, :with => :service_name do
      render :service
    end

    get :index do
      render :index
    end
  end
end
