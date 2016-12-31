class HCast::Casters::StringCaster

  def self.cast(value, attr_name, options = {})
    return value      if value.is_a?(String)
    return value.to_s if value.is_a?(Symbol)
    raise HCast::Errors::CastingError, "should be a string"
  end
end
