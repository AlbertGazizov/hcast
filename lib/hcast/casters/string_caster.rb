class HCast::Casters::StringCaster

  def self.cast(value, attr_name)
    if value.is_a?(String)
      value
    elsif value.is_a?(Symbol)
      value.to_s
    else
      raise HCast::Errors::CastingError, "#{attr_name} should be a string"
    end
  end

end
