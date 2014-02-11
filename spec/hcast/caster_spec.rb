require 'spec_helper'

describe HCast::Caster do
  describe "#cast" do

    class ContactCaster
      include HCast::Caster

      attributes do
        hash :contact do
          string   :name
          integer  :age, optional: true
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
          age: "22",
          weight: "65.5",
          birthday: "2014-02-02",
          last_logged_in: "2014-02-02 10:10:00",
          last_visited_at: "2014-02-02 10:10:00",
          company: {
            name: "MyCo",
          },
          emails: [ "test@example.com", "test2@example.com" ],
          social_accounts: [
            {
              name: "john_smith",
              type: 'twitter',
            },
            {
              name: "John",
              type: :facebook,
            },
          ]
        }
      }

      casted_hash = ContactCaster.cast(input_hash)

      casted_hash.should == {
        contact: {
          name: "John Smith",
          age: 22,
          weight: 65.5,
          birthday: Date.parse("2014-02-02"),
          last_logged_in: DateTime.parse("2014-02-02 10:10:00"),
          last_visited_at: Time.parse("2014-02-02 10:10:00"),
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
    end

    it "should raise error if some attribute can't be casted" do
      input_hash = {
        contact: {
          name: {},
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
            }
          ]
        }
      }

      expect do
        ContactCaster.cast(input_hash)
      end.to raise_error(HCast::Errors::CastingError, "name should be a string")
    end

    it "should raise error if some attribute wasn't given" do
      input_hash = {
        contact: {
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
            }
          ]
        }
      }

      expect do
        ContactCaster.cast(input_hash)
      end.to raise_error(HCast::Errors::MissingAttributeError, "name should be given")
    end

    it "should not raise error if attribute is optional" do
      input_hash = {
        contact: {
          name: "Jim",
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

      expect do
        ContactCaster.cast(input_hash)
      end.to_not raise_error
    end

    it "should raise error if unexpected attribute was given" do
      input_hash = {
        wrong_attribute: 'foo',
        contact: {
          name: "Jim",
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

      expect do
        ContactCaster.cast(input_hash)
      end.to raise_error(HCast::Errors::UnexpectedAttributeError, "Unexpected attributes given: [:wrong_attribute]")
    end

    it "should convert accept hash with string keys and cast them to symbol keys" do
      input_hash = {
        'contact' => {
          'name' => "John Smith",
          'age' => "22",
          'weight' => "65.5",
          'birthday' => "2014-02-02",
          'last_logged_in' => "2014-02-02 10:10:00",
          'last_visited_at' => "2014-02-02 10:10:00",
          'company' => {
            'name' => "MyCo",
          },
          'emails' => [ "test@example.com", "test2@example.com" ],
          'social_accounts' => [
            {
             'name' => "john_smith",
             'type' => 'twitter',
            },
            {
             'name' => "John",
             'type' => :facebook,
            },
          ]
        }
      }

      casted_hash = ContactCaster.cast(input_hash, input_keys: :string, output_keys: :symbol)

      casted_hash.should == {
        contact: {
          name: "John Smith",
          age: 22,
          weight: 65.5,
          birthday: Date.parse("2014-02-02"),
          last_logged_in: DateTime.parse("2014-02-02 10:10:00"),
          last_visited_at: Time.parse("2014-02-02 10:10:00"),
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
    end
  end

  context "checking invalid parameters" do
    it "should raise CaterNotFound exception if caster name is invalid" do
      expect do
        class WrongCaster
          include HCast::Caster

          attributes do
            integr   :name
          end
        end
      end.to raise_error(HCast::Errors::CasterNotFoundError)
    end
  end

  context "validations" do
    before :all do
      class ContactWithValidationsCaster
        include HCast::Caster

        attributes do
          hash :contact do
            string   :name, presence: true, length: { max: 5 }
            integer  :age, optional: true
            float    :weight, numericality: { less_than_or_equal_to: 200 }
            date     :birthday
            datetime :last_logged_in
            time     :last_visited_at
            hash :company do
              string :name, length: { min: 2 }
            end
            array :emails, each: :string
            array :social_accounts, each: :hash do
              string :name
              symbol :type, inclusion: { in: [:twitter, :facebook] }
            end
          end
        end
      end
    end

    it "should collect validation errors and raise exception when hash is invalid" do
      begin
        ContactWithValidationsCaster.cast(
          contact: {
            name: "John Smith",
            age: "22",
            weight: "65.5",
            birthday: "2014-02-02",
            last_logged_in: "2014-02-02 10:10:00",
            last_visited_at: "2014-02-02 10:10:00",
            company: {
              name: "MyCo",
            },
            emails: [ "test@example.com", "test2@example.com" ],
            social_accounts: [
              {
                name: "john_smith",
                type: 'twitter',
              },
              {
                name: "John",
                type: :yahoo,
              },
            ]
          }
        )
      rescue HCast::Errors::ValidationError => e
        e.errors.to_hash.should == {
          contact: {
            name: ["can't be more than 5"],
            social_accounts: [
              {},
              { type: ["should be included in [:twitter, :facebook]"] },
            ]
          }
        }
      end
    end
  end
end
