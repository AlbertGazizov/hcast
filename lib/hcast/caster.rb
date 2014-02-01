module HCast::Caster
  extend ActiveSupport::Concern

  included do
    @@attributes = []
  end

  module ClassMethods
    def rules(&block)
      raise ArgumentError, "You should provide block" unless block_given?

      attributes = HCast::RulesParser.parse(&block)
      self.class_variable_set(:@@attributes, attributes)
    end
  end

  def cast(hash)
    check_rules_defined!

    cast_attributes(hash, @@attributes)
  end

  def cast_attributes(hash, attributes)
    casted_hash = {}
    attributes.each do |attribute|
      value = hash[attribute.name]
      casted_hash[attribute.name] = attribute.caster.cast(value, attribute.name)
      if attribute.has_children?
        cast_attributes(value, attribute.children)
      end
    end

    casted_hash
  end

  private

  def check_rules_defined!
    unless self.class.class_variable_defined?(:@@attributes)
      raise HCast::Errors::ArgumentError, "Rules undefined"
    end
  end

  def cast_attribute(attribute, hash, errors)
  end
end
