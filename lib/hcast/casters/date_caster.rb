class HCast::Casters::DateCaster

  def self.cast(value, attr_name, options = {})
    if value.is_a?(Date)
      value
    elsif value.is_a?(String)
      begin
        Date.parse(value)
      rescue ArgumentError => e
        raise HCast::Errors::CastingError, "#{attr_name} is invalid date"
      end
    else
      raise HCast::Errors::CastingError, "#{attr_name} should be a date"
    end
  end

end
