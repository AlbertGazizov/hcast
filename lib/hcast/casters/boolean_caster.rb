class HCast::Casters::BooleanCaster

  def self.cast(value, attr_name)
    if [TrueClass, FalseClass].exclude?(value.class)
      raise HCast::Errors::CastingError, "#{attr_name} should be a boolean"
    end
  end

end
