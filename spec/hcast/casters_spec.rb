require 'spec_helper'

describe "Casters" do
  context HCast::Casters::BooleanCaster do
    def cast(v)
      HCast::Casters::BooleanCaster.cast(v, :attr_name)
    end
    it "works with real booleans" do
      expect(cast(true)).to eq(true)
      expect(cast(false)).to eq(false)
    end

    it "works with trueish values" do
      expect(cast(1)).to eq(true)
      expect(cast("1")).to eq(true)
      expect(cast("on")).to eq(true)
      expect(cast("true")).to eq(true)
    end

    it "works with falsish values" do
      expect(cast("0")).to eq(false)
      expect(cast("false")).to eq(false)
      expect(cast("off")).to eq(false)
      expect(cast(0)).to eq(false)
    end

    it "raises else with falsish values" do
      expect{
        cast("something")
      }.to raise_error(HCast::Errors::CastingError)
    end
  end
end
