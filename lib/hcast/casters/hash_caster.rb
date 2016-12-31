class HCast::Casters::HashCaster

  def self.cast(value, attr_name, options = {})
    return value if value.is_a?(Hash)
    raise HCast::Errors::CastingError, "should be a hash"
  end

end
