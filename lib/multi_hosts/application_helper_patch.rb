Rails.logger.info "LOADING ApplicationHelperPatch"

module MultiHosts
  module ApplicationHelperPatch
    def page_header_title
      $stderr.puts "PAGE_HEADER PATCH CALLED via stderr"
      Rails.logger.info "PAGE_HEADER PATCH CALLED: @current_multihost=#{@current_multihost.inspect}"
      if @current_multihost && @current_multihost.app_title.present?
        h(@current_multihost.app_title)
      else
        super
      end
    end
  end
end
