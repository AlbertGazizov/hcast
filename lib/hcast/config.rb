class HCast::Config
  attr_accessor :input_keys, :outpu_keys

  def input_keys
    @input_keys || :symbol
  end

  def output_keys
    @output_keys || :symbol
  end
end
