class HCast::Casters::BooleanCaster

  def self.cast(value, attr_name, options = {})
    if [TrueClass, FalseClass].include?(value.class)
      value
    elsif ['1', 'true', 'on', 1].include?(value)
      true
    elsif ['0', 'false', 'off', 0].include?(value)
      false
    else
      raise HCast::Errors::CastingError, "should be a boolean"
    end
  end

end
