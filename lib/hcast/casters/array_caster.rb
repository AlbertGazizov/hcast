class HCast::Casters::ArrayCaster

  def self.cast(value, attr_name, options = {})
    if value.is_a?(Array)
      if options[:each]
        cast_array_items(value, attr_name, options)
      else
        value
      end
    else
      raise HCast::Errors::CastingError, "#{attr_name} should be an array"
    end
  end

  private

  def self.cast_array_items(array, attr_name, options)
    caster_name = options[:each]
    caster = HCast.casters[caster_name]
    check_caster_exists!(caster, caster_name)
    array.map do |item|
      caster.cast(item, "#{attr_name} item", options)
    end
  end

  def self.check_caster_exists!(caster, caster_name)
    unless caster
      raise HCast::Errors::CasterNotFoundError, "caster with name #{caster_name} is not found"
    end
  end

end
