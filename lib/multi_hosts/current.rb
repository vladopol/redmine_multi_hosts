# Placeholder - not used, Thread.current used instead
module MultiHosts
  class Current
    def self.multihost
      Thread.current[:multihost]
    end

    def self.multihost=(val)
      Thread.current[:multihost] = val
    end
  end
end
