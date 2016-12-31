class HCast::Casters::BooleanCaster
  REAL_BOOLEANS = [TrueClass, FalseClass]
  TRUE_VALUES   = ['1', 'true', 'on', 1]
  FALSE_VALUES  = ['0', 'false', 'off', 0]

  def self.cast(value, attr_name, options = {})
    if REAL_BOOLEANS.include?(value.class)
      value
    elsif TRUE_VALUES.include?(value)
      true
    elsif FALSE_VALUES.include?(value)
      false
    else
      raise HCast::Errors::CastingError, "should be a boolean"
    end
  end

end
