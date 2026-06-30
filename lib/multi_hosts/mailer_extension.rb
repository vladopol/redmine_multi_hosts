module MultiHosts
  module MailerExtension

    extend ActiveSupport::Concern

    included do
      after_action :set_multi_host_urls
    end

    def set_multi_host_urls
      forced_host = project_multi_host
      user_multi_host = forced_host || MultiHosts::Current.multihost || (non_default_host_user_present? ? non_default_host_users.first.multi_host : nil)

      # Without an explicit project binding, the default host doesn't need any
      # overrides: the email already goes out through the main SMTP configured
      # in configuration.yml. An explicit project binding to the default host,
      # however, means "always use the default organization, regardless of
      # login domain" and must still apply its SMTP/from settings to override
      # whatever the login-domain logic would otherwise pick.
      return unless user_multi_host
      return if user_multi_host.is_default? && forced_host.nil?

      default_host = MultiHost.default.full_hostname
      target_host  = user_multi_host.full_hostname

      if user_multi_host.default_mail_from.present?
        message.from = user_multi_host.default_mail_from
      end

      if user_multi_host.app_title.present?
        message.subject = message.subject.gsub(Setting.app_title_original, user_multi_host.app_title)
      end

      if user_multi_host.smtp_address.present?
        message.delivery_method.settings.merge!(
          address: user_multi_host.smtp_address,
          port: user_multi_host.smtp_port || 25,
          user_name: user_multi_host.smtp_user,
          password: user_multi_host.smtp_password,
          authentication: (user_multi_host.smtp_authentication || 'login').to_sym
        )
      end

      [:html_part, :text_part].each do |partname|
        mcontent = message.send(partname).body.raw_source
        mcontent.gsub!(default_host, target_host) unless target_host == default_host
        if user_multi_host.app_title.present?
          mcontent.gsub!(Setting.app_title_original, user_multi_host.app_title)
        end
        message.send(partname).body.raw_source.replace(mcontent)
      end
    end

    # Reads the 'X-Redmine-Project' header that core Redmine adds to issue,
    # document, news, message and wiki notification emails, and returns the
    # multi_host attached to that project, if any.
    # This takes priority over the login-domain-based detection so that
    # notifications always go out through the organization that owns the
    # project, regardless of which domain the triggering user was logged
    # in through.
    def project_multi_host
      identifier = message.header['X-Redmine-Project']&.value
      return nil if identifier.blank?

      project = Project.find_by(identifier: identifier)
      return nil unless project

      project.respond_to?(:multi_host) ? project.multi_host : nil
    rescue StandardError
      nil
    end

    def all_recipients
      [message.to, message.cc, message.bcc].flatten.compact.uniq
    end

    def all_recipient_users
      @_all_recipient_users ||= ::EmailAddress.where(address: all_recipients).map(&:user).uniq
    end

    def non_default_host_user_present?
      non_default_host_users.any?
    end

    def non_default_host_users
      @_non_default_host_users ||= all_recipient_users.select(&:non_default_host_user?)
    end

  end
end
