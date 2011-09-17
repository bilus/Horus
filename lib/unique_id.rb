require 'uuidtools'

class UniqueId
  def initialize
    # FIXME Extract into UniqueGameId class.
    seed = UUIDTools::UUID.random_create
    @id = UUIDTools::UUID.md5_create(UUIDTools::UUID_DNS_NAMESPACE, "www.xtreeme.com/#{seed}")
  end
  def to_s
    @id.to_s
  end
end