module MultiHosts
  class Hooks < Redmine::Hook::ViewListener
    # Adds an Organization (MultiHost) selector to the project settings form.
    # When set, all email notifications for this project will be sent using
    # that host's SMTP settings and branding, regardless of which domain
    # the triggering user is logged in through.
    def view_projects_form(context = {})
      project = context[:project]
      return '' unless project

      hosts = MultiHost.all
      return '' if hosts.empty?

      context[:controller].view_context.render(
        partial: 'multi_hosts/project_multi_host_field',
        locals: { project: project, hosts: hosts }
      )
    end
  end
end
