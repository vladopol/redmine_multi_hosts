class AddSmtpSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :multi_hosts, :smtp_address, :string
    add_column :multi_hosts, :smtp_port, :integer
    add_column :multi_hosts, :smtp_user, :string
    add_column :multi_hosts, :smtp_password, :string
    add_column :multi_hosts, :smtp_authentication, :string, default: 'login'
  end
end
