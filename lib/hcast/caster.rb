module HCast::Caster
  extend ActiveSupport::Concern

  included do
    @@attributes = []
  end

  module ClassMethods
    def attributes(&block)
      raise ArgumentError, "You should provide block" unless block_given?

      attributes = HCast::AttributesParser.parse(&block)
      self.class_variable_set(:@@attributes, attributes)
    end
  end

  def cast(hash)
    check_attributes_defined!
    cast_attributes(hash, @@attributes)
  end

  def cast_attributes(hash, attributes)
    casted_hash = {}
    attributes.each do |attribute|
      if hash.has_key?(attribute.name)
        casted_hash[attribute.name] = cast_attribute(hash, attribute)
        if attribute.has_children?
          casted_hash[attribute.name] = cast_children(hash, attribute)
        end
      else
        if attribute.required?
          raise HCast::Errors::MissingAttributeError, "#{attribute.name} should be given"
        end
      end
    end
    casted_hash
  end

  private

  def check_attributes_defined!
    unless self.class.class_variable_defined?(:@@attributes)
      raise HCast::Errors::ArgumentError, "Attributes block should be defined"
    end
  end

  def cast_attribute(hash, attribute)
    attribute.caster.cast(hash[attribute.name], attribute.name, attribute.options)
  end

  def cast_children(hash, attribute)
    if attribute.caster == HCast::Casters::ArrayCaster
      hash[attribute.name].map do |val|
        cast_attributes(val, attribute.children)
      end
    else
      cast_attributes(hash[attribute.name], attribute.children)
    end
  end
end
