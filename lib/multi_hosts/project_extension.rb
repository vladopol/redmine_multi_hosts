module MultiHosts
  module ProjectExtension
    extend ActiveSupport::Concern

    included do
      belongs_to :multi_host
      safe_attributes 'multi_host_id'
    end
  end
end
