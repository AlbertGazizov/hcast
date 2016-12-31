class HCast::Casters::DateTimeCaster

  def self.cast(value, attr_name, options = {})
    return value               if value.is_a?(DateTime)
    return value.to_datetime   if value.is_a?(Time)
    return parse_string(value) if value.is_a?(String)
    raise HCast::Errors::CastingError, "should be a datetime"
  end

  def self.parse_string(value)
    DateTime.parse(value)
  rescue ArgumentError => e
    raise HCast::Errors::CastingError, "is invalid datetime"
  end
end
