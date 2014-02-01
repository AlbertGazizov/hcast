class HCast::Casters::ArrayCaster

  def self.cast(value, attr_name)
    if value.is_a?(Array)
      value
    else
      raise HCast::Errors::CastingError, "#{attr_name} should be an array"
    end
  end

end
