require 'spec_helper'

describe HCast::Caster do
  describe "#cast" do

    class ContactCaster
      include HCast::Caster

      rules do
        hash :contact do
          string   :name
          integer  :age
          float    :weight
          date     :birthday
          datetime :last_logged_in
          time     :last_visited_at
          hash :company do
            string :name
          end
          array :emails, each: :string
          array :social_accounts, each: :hash do
            string :name
            symbol :type
          end
        end
      end
    end

    it "should cast hash attributes" do
      input_hash = {
        contact: {
          name: "John Smith",
          age: 22,
          weight: 65.5,
          birthday: Date.today,
          last_logged_in: DateTime.now,
          last_visited_at: Time.now,
          company: {
            name: "MyCo",
          },
          emails: [ "test@example.com", "test2@example.com" ],
          social_accounts: [
            {
              name: "john_smith",
              type: :twitter,
            },
            {
              name: "John",
              type: :facebook,
            },
          ]
        }
      }

      casted_hash = ContactCaster.new.cast(input_hash)

      casted_hash.should == input_hash
    end

    it "should raise error if some attribute can't be casted" do
      input_hash = {
        contact: {
          name: {},
        }
      }

      expect do
        ContactCaster.new.cast(input_hash)
      end.to raise_error(HCast::Errors::CastingError, "name should be a string")
    end
  end
end
