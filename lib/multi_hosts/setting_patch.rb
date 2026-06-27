module MultiHosts
  module SettingPatch
    def self.included(base)
      base.class_eval do
        class << self
          alias_method :host_name_original, :host_name
          alias_method :app_title_original, :app_title

          def host_name
            if Thread.current[:current_multihost]
              Thread.current[:current_multihost].host
            else
              host_name_original
            end
          end

          def app_title
            if Thread.current[:current_multihost] && Thread.current[:current_multihost].app_title.present?
              Thread.current[:current_multihost].app_title
            else
              app_title_original
            end
          end
        end
      end
    end
  end
end
