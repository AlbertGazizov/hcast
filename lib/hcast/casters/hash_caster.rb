class HCast::Casters::HashCaster

  def self.cast(value, attr_name)
    if value.is_a?(Hash)
      value
    else
      raise HCast::Errors::CastingError, "#{attr_name} should be a hash"
    end
  end

end
