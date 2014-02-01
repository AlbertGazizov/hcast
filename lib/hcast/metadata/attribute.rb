module HCast::Metadata
  class Attribute
    attr_reader :name, :caster, :options
    attr_accessor :children

    def initialize(name, caster, options)
      @name      = name
      @caster    = caster
      @options   = options
      @children  = []
    end

    def has_children?
      !children.empty?
    end

  end
end
