class HCast::Casters::IntegerCaster

  def self.cast(value, attr_name)
    if value.is_a?(Integer)
      value
    elsif value.is_a?(String)
      begin
        Integer(value)
      rescue ArgumentError => e
        raise HCast::Errors::CastingError, "#{attr_name} is invalid integer"
      end
    else
      raise HCast::Errors::CastingError, "#{attr_name} should be a integer"
    end
  end

end
