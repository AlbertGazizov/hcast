class HCast::Casters::BooleanCaster

  def self.cast(value, attr_name, options = {})
    if [TrueClass, FalseClass].include?(value.class)
      value
    elsif ['1', 'true', 1].include?(value)
      true
    elsif ['0', 'false', 0].include?(value)
      false
    else
      raise HCast::Errors::CastingError, "#{attr_name} should be a boolean"
    end
  end

end
