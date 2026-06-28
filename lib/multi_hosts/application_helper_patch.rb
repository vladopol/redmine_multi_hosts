module MultiHosts
  module ApplicationHelperPatch
    def page_header_title
      if @current_multihost && @current_multihost.app_title.present?
        h(@current_multihost.app_title)
      else
        super
      end
    end
  end
end
