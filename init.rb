Redmine::Plugin.register :redmine_multi_hosts do
  name 'Redmine MultiHosts'
  author 'Florian Eck for akquinet (fork by vladopol)'
  description 'Allow to use one Redmine installation with multiple hosts, each with its own branding, sender address, SMTP settings and per-project organization binding'
  version '2.0'
  url 'https://github.com/vladopol/redmine_multi_hosts'
  author_url 'https://github.com/vladopol'
end

require "multi_hosts/mailer_extension"
require "multi_hosts/user_extension"
require "multi_hosts/project_extension"
require "multi_hosts/hooks"
require "multi_hosts/detect_host"
require "multi_hosts/multi_hosts_helper"
require "multi_hosts/setting_patch"
require "multi_hosts/current"
require "multi_hosts/application_helper_patch"

begin
  EasyUserType
rescue Exception
end



Rails.application.config.after_initialize do
  ActiveJob::Base.queue_adapter = :inline
  Mailer.send(:include, MultiHosts::MailerExtension)
  User.send(:include, MultiHosts::UserExtension)
  Project.send(:include, MultiHosts::ProjectExtension)
  ApplicationController.send(:include, MultiHosts::DetectHost)
  AccountController.send(:include, MultiHosts::RegisterWithHostname)
  Setting.send(:include, MultiHosts::SettingPatch)
  ApplicationHelper.send(:prepend, MultiHosts::ApplicationHelperPatch)
  ApplicationHelper.send(:include, MultiHostsHelper)

  Redmine::MenuManager.map :admin_menu do |menu|
    menu.push :multi_hosts, :multi_host_settings_path, :caption => :multi_hosts, :html => {:class => 'icon icon-projects'}, :if => Proc.new {User.current.admin?}
  end
end

ActiveSupport.on_load(:action_view) do
  ActionView::Base.prepend(MultiHosts::ApplicationHelperPatch)
  prepend MultiHosts::ApplicationHelperPatch
end

Rails.application.config.to_prepare do
  ActionView::Base.prepend(MultiHosts::ApplicationHelperPatch)
end

Rails.application.config.to_prepare do
  ApplicationHelper.module_eval do
    def page_header_title
      if @current_multihost && @current_multihost.app_title.present?
        h(@current_multihost.app_title)
      else
        h(Setting.app_title)
      end
    end
  end
end
