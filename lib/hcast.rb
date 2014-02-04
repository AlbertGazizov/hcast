require 'active_support/concern.rb'

require 'hcast/version'
require 'hcast/errors'
require 'hcast/config'
require 'hcast/casters'
require 'hcast/metadata/attribute'
require 'hcast/attributes_parser'
require 'hcast/caster'

module HCast
  @@casters = {}

  # Defines caster without adding own class
  # @note Not yet implemented
  def self.create(&block)
  end

  # Returns list of defined casters
  def self.casters
    @@casters
  end

  # Adds new casters to HCast
  # Allow extend HCast with your own casters
  # @param caster_name [Symbol] caster name
  # @param caster      [Class]  caster
  def self.add_caster(caster_name, caster)
    @@casters[caster_name] = caster
  end

  def self.config
    @@config ||= HCast::Config.new
  end
end

HCast.add_caster(:array,    HCast::Casters::ArrayCaster)
HCast.add_caster(:boolean,  HCast::Casters::BooleanCaster)
HCast.add_caster(:date,     HCast::Casters::DateCaster)
HCast.add_caster(:datetime, HCast::Casters::DateTimeCaster)
HCast.add_caster(:float,    HCast::Casters::FloatCaster)
HCast.add_caster(:hash,     HCast::Casters::HashCaster)
HCast.add_caster(:integer,  HCast::Casters::IntegerCaster)
HCast.add_caster(:string,   HCast::Casters::StringCaster)
HCast.add_caster(:symbol,   HCast::Casters::SymbolCaster)
HCast.add_caster(:time,     HCast::Casters::TimeCaster)
