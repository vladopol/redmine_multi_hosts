module MultiHosts
  module DetectHost
    extend ActiveSupport::Concern

    included do
      before_action :detect_multi_host
      helper_method :current_multihost
    end

    def current_multihost
      @current_multihost
    end

    private

    def detect_multi_host
      @current_multihost = MultiHost.find_by(host: request.env['HTTP_HOST'])
      if @current_multihost.nil?
        session[:current_multi_host_name] = 'unknown'
        MultiHosts::Current.multihost = nil
      elsif @current_multihost.is_default?
        session[:current_multi_host_name] = 'default'
        MultiHosts::Current.multihost = nil
      else
        session[:current_multi_host_name] = @current_multihost.internal_name
        Thread.current[:current_multi_host_name] = @current_multihost.internal_name
        MultiHosts::Current.multihost = @current_multihost
      end
    end
  end
end
