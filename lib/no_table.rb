class NoTable
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include ActiveModel::Validations
  include ActiveModel::AttributeMethods

  class_attribute :_attributes
  self._attributes = []

  def self.attributes(*names)
    attr_accessor *names
    define_attribute_methods names
    self._attributes += names
  end

  def attributes
    self._attributes.inject({}) do |hash, attr|
      hash[attr.to_s] = send(attr)
      hash
    end
  end

  def initialize(attributes = {})
    attrs = normalize_date_params(attributes)

    attrs.each do |attr, value|
      send("#{attr}=" , value) if respond_to?("#{attr}=")
    end unless attributes.blank?
  end

  def persisted?
    false
  end

  private

  def normalize_date_params(attributes)
    return attributes if attributes.blank?
    attrs = attributes.clone
    attrs.clone.each do |condition, value|
      if condition =~ /(.*)\(1i\)$/ # if a condition name ends with "(1i)", assume it's date / datetime
        date_scope_name = $1
        date_parts = (1..6).to_a.map do |idx|
          attrs.delete("#{ date_scope_name }(#{ idx }i)")
        end.reject{|s| s.blank? }.map{|s| s.to_i }

        if date_parts.length >= 3 # did we get enough info to build a time?
          attrs[date_scope_name] = Time.zone.local(*date_parts)
        end
      end
    end

    attrs
  end
end

