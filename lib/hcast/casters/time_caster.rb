class HCast::Casters::TimeCaster

  def self.cast(value, attr_name)
    if value.is_a?(Time)
      value
    elsif value.is_a?(String)
      begin
        Time.parse(value)
      rescue ArgumentError => e
        raise HCast::Errors::CastingError, "#{attr_name} is invalid time"
      end
    else
      raise HCast::Errors::CastingError, "#{attr_name} should be a time"
    end
  end

end
