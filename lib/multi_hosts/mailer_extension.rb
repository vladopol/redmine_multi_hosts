module MultiHosts
  module MailerExtension

    extend ActiveSupport::Concern

    included do
      after_action :set_multi_host_urls
    end

    def set_multi_host_urls
      if non_default_host_user_present? || Thread.current[:current_multihost]
        default_host = MultiHost.default.full_hostname
        user_multi_host = Thread.current[:current_multihost] || non_default_host_users.first.multi_host
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
            authentication: user_multi_host.smtp_authentication || 'login'
          )
        end

        [:html_part, :text_part].each do |partname|
          mcontent = message.send(partname).body.raw_source
          mcontent.gsub!(default_host, target_host)

          if user_multi_host.app_title.present?
            mcontent.gsub!(Setting.app_title_original, user_multi_host.app_title)
          end

          message.send(partname).body.raw_source.replace(mcontent)
        end
      end
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
