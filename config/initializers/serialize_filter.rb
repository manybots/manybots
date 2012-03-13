require 'json'
class SerializeFilter

  def initialize(attribute)
    @attribute = attribute.to_s
  end

  def before_save(record)
    record.send("#{@attribute}=", SerializeFilter.encrypt(record.send("#{@attribute}")))
  end

  def after_save(record)
    record.send("#{@attribute}=", SerializeFilter.decrypt(record.send("#{@attribute}")))
  end

  def self.encrypt(value)
    value.to_json
  end

  def self.decrypt(value)
    JSON.parse(value) rescue value
  end
end
