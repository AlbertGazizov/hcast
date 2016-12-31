class HCast::Casters::ArrayCaster

  def self.cast(value, attr_name, options = {})
    raise HCast::Errors::CastingError, "should be an array" unless value.is_a?(Array)
    return value unless options[:each]

    cast_array_items(value, attr_name, options)
  end

  private

  def self.cast_array_items(array, attr_name, options)
    caster_name = options[:each]
    caster      = HCast.casters[caster_name]
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
