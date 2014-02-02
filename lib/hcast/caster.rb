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
  def cast(hash)
    check_attributes_defined!
    cast_attributes(hash, @@attributes)
  end

  private

  def cast_attributes(hash, attributes)
    casted_hash = {}
    attributes.each do |attribute|
      if hash.has_key?(attribute.name)
        casted_hash[attribute.name] = cast_attribute(hash, attribute)
        if attribute.has_children?
          casted_hash[attribute.name] = cast_children(hash, attribute)
        end
      else
        if attribute.required?
          raise HCast::Errors::MissingAttributeError, "#{attribute.name} should be given"
        end
      end
    end
    casted_hash
  end

  def cast_attribute(hash, attribute)
    attribute.caster.cast(hash[attribute.name], attribute.name, attribute.options)
  end

  def cast_children(hash, attribute)
    if attribute.caster == HCast::Casters::ArrayCaster
      hash[attribute.name].map do |val|
        cast_attributes(val, attribute.children)
      end
    else
      cast_attributes(hash[attribute.name], attribute.children)
    end
  end

  def check_attributes_defined!
    unless self.class.class_variable_defined?(:@@attributes)
      raise HCast::Errors::ArgumentError, "Attributes block should be defined"
    end
  end
end
