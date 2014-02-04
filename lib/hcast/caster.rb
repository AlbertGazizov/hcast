# Include this module to create your caster
#
# Example caster:
#   class ContactCaster
#     include HCast::Caster
#
#     attributes do
#       hash :contact do
#         string   :name
#         integer  :age, optional: true
#         float    :weight
#         date     :birthday
#         datetime :last_logged_in
#         time     :last_visited_at
#         hash :company do
#           string :name
#         end
#         array :emails, each: :string
#         array :social_accounts, each: :hash do
#           string :name
#           symbol :type
#         end
#       end
#     end
#   end
#
# The defined caster will have #cast method which accepts hash
# Use it to cast hash:
#   ContactCaster.new.cast({
#     contact: {
#       name: "John Smith",
#       age: "22",
#       weight: "65.5",
#       birthday: "2014-02-02",
#       last_logged_in: "2014-02-02 10:10:00",
#       last_visited_at: "2014-02-02 10:10:00",
#       company: {
#         name: "MyCo",
#       },
#       emails: [ "test@example.com", "test2@example.com" ],
#       social_accounts: [
#         {
#           name: "john_smith",
#           type: 'twitter',
#         },
#         {
#           name: "John",
#           type: :facebook,
#         },
#       ]
#     }
#   })
#
#   The output will be casted hash:
#   {
#     contact: {
#       name: "John Smith",
#       age: 22,
#       weight: 65.5,
#       birthday: Date.parse("2014-02-02"),
#       last_logged_in: DateTime.parse("2014-02-02 10:10:00"),
#       last_visited_at: Time.parse("2014-02-02 10:10:00"),
#       company: {
#         name: "MyCo",
#       },
#       emails: [ "test@example.com", "test2@example.com" ],
#       social_accounts: [
#         {
#           name: "john_smith",
#           type: :twitter,
#         },
#         {
#           name: "John",
#           type: :facebook,
#         },
#       ]
#     }
#   }
module HCast::Caster
  extend ActiveSupport::Concern

  included do
    # Stores caster attributes
    @@attributes = []
  end

  module ClassMethods

    # Defines casting rules
    # @example
    #  attributes do
    #    string   :first_name
    #    string   :last_name
    #    integer  :age, optional: true
    #  end
    def attributes(&block)
      raise ArgumentError, "You should provide block" unless block_given?

      attributes = HCast::AttributesParser.parse(&block)
      self.class_variable_set(:@@attributes, attributes)
    end
  end

  # Performs casting
  # @param hash [Hash] hash for casting
  # @param options [Hash] options, input_keys: :string, output_key: :symbol
  def cast(hash, options = {})
    check_attributes_defined!
    check_hash_given!(hash)
    check_options!(options)
    set_default_options(options)
    cast_attributes(hash, @@attributes, options)
  end

  private

  def cast_attributes(hash, attributes, options)
    casted_hash = {}
    hash_keys = get_keys(hash, options)
    attributes.each do |attribute|
      if hash_keys.include?(attribute.name)
        casted_hash[attribute.name] = cast_attribute(hash, attribute, options)
        if attribute.has_children?
          casted_hash[attribute.name] = cast_children(hash, attribute, options)
        end
      else
        if attribute.required?
          raise HCast::Errors::MissingAttributeError, "#{attribute.name} should be given"
        end
      end
    end
    check_unexpected_attributes_not_given!(hash_keys, casted_hash.keys)
    casted_hash
  end

  def cast_attribute(hash, attribute, options)
    value = get_value(hash, attribute.name, options)
    attribute.caster.cast(value, attribute.name, attribute.options)
  end

  def cast_children(hash, attribute, options)
    value = get_value(hash, attribute.name, options)
    if attribute.caster == HCast::Casters::ArrayCaster
      value.map do |val|
        cast_attributes(val, attribute.children, options)
      end
    else
      cast_attributes(value, attribute.children, options)
    end
  end

  def get_keys(hash, options)
    if options[:input_keys] != options[:output_keys]
      if options[:input_keys] == :symbol
        hash.keys.map(&:to_s)
      else
        hash.keys.map(&:to_sym)
      end
    else
      hash.keys
    end
  end

  def get_value(hash, key, options)
    if options[:input_keys] != options[:output_keys]
      if options[:input_keys] == :symbol
        hash[key.to_sym]
      else
        hash[key.to_s]
      end
    else
      hash[key]
    end
  end

  def check_attributes_defined!
    unless self.class.class_variable_defined?(:@@attributes)
      raise HCast::Errors::ArgumentError, "Attributes block should be defined"
    end
  end

  def check_options!(options)
    unless options.is_a?(Hash)
      raise HCast::Errors::ArgumentError, "Options should be a hash"
    end
    if options[:input_keys] && ![:string, :symbol].include?(options[:input_keys])
      raise HCast::Errors::ArgumentError, "input_keys should be :string or :symbol"
    end
    if options[:output_keys] && ![:string, :symbol].include?(options[:output_keys])
      raise HCast::Errors::ArgumentError, "output_keys should be :string or :symbol"
    end
  end

  def check_hash_given!(hash)
    unless hash.is_a?(Hash)
      raise HCast::Errors::ArgumentError, "Hash should be given"
    end
  end

  def check_unexpected_attributes_not_given!(input_hash_keys, casted_hash_keys)
    unexpected_keys = input_hash_keys - casted_hash_keys
    unless unexpected_keys.empty?
      raise HCast::Errors::UnexpectedAttributeError, "Unexpected attributes given: #{unexpected_keys}"
    end
  end

  def set_default_options(options)
    options[:input_keys]  ||= HCast.config.input_keys
    options[:output_keys] ||= HCast.config.output_keys
  end
end
