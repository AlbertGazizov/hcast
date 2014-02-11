class HCast::AttributesCaster
  attr_reader :attributes, :validation_errors, :options, :validation_context

  def initialize(attributes, options, validation_context)
    @attributes        = attributes
    @options           = options
    @validation_errors = AttrValidator::ValidationErrors.new
  end

  def has_validation_errors?
    !validation_errors.empty?
  end

  def cast(input_hash)
    casted_hash = {}

    hash_keys = get_keys(input_hash)
    attributes.each do |attribute|
      if hash_keys.include?(attribute.name)
         casted_value = cast_attribute(attribute, input_hash)
         casted_hash[attribute.name] = casted_value
         validate_attribute(attribute, casted_hash, input_hash)
      else
        raise HCast::Errors::MissingAttributeError, "#{attribute.name} should be given" if attribute.required?
      end
    end
    check_unexpected_attributes_not_given!(hash_keys, casted_hash.keys)

    casted_hash
  end

  private

  def validate_attribute(attribute, casted_hash, input_hash)
    casted_value = casted_hash[attribute.name]
    attribute.options.each do |key, options|
      if validator = AttrValidator.validators[key]
        error_messages = validator.validate(casted_value, options)
        unless error_messages.empty?
          validation_errors.add_all(attribute.name, error_messages)
          break
        end
      elsif key == :validate
        validation_context.send(options, casted_hash, input_hash, validation_errors)
      end
    end
  end

  def cast_attribute(attribute, hash)
    value        = get_value(hash, attribute.name)
    casted_value = attribute.caster.cast(value, attribute.name, attribute.options)

    if attribute.has_children?
      cast_children(hash, attribute)
    else
      casted_value
    end
  end

  def cast_children(hash, attribute)
    value = get_value(hash, attribute.name)
    if attribute.caster == HCast::Casters::ArrayCaster
      errors_list = []
      casted_values = value.map do |val|
        caster = self.class.new(attribute.children, options, validation_context)
        casted_value = caster.cast(val)
        errors_list << caster.validation_errors.to_hash
        casted_value
      end
      if errors_list.any? { |errors| !errors.empty? }
        validation_errors.messages[attribute.name] ||= []
        validation_errors.messages[attribute.name] += errors_list
      end
      casted_values
    else
      caster = self.class.new(attribute.children, options, validation_context)
      casted_value = caster.cast(value)
      if caster.has_validation_errors?
        validation_errors.messages[attribute.name] = caster.validation_errors.to_hash
      end
      casted_value
    end
  end

  def get_keys(hash)
    if options[:input_keys] != options[:output_keys]
      if options[:input_keys] == :symbol
        hash.keys.map(&:to_s)
      else
        hash.keys.map(&:to_sym)
      end
    else
      hash.keys
    end
  end

  def get_value(hash, key)
    if options[:input_keys] != options[:output_keys]
      if options[:input_keys] == :symbol
        hash[key.to_sym]
      else
        hash[key.to_s]
      end
    else
      hash[key]
    end
  end

  def check_unexpected_attributes_not_given!(input_hash_keys, casted_hash_keys)
    unexpected_keys = input_hash_keys - casted_hash_keys
    unless unexpected_keys.empty?
      raise HCast::Errors::UnexpectedAttributeError, "Unexpected attributes given: #{unexpected_keys}"
    end
  end

end
