require 'spec_helper'

describe HCast do
  it "should cast hash attributes" do
    hash = {
      contact: {
        name: "John Smith",
        age: 22,
        weight: 65.5,
        birthday: Date.today,
        last_logged_in: DateTime.now,
        last_visited_at: Time.now,
        company: {
          name: "MyCo"
        }
        emails: [ "test@example.com", "test2@example.com" },
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

    caster = HCast.create do
      hash :contact do
        string   :name,          required: true
        integer  :age,           inclusion: 1..90
        float    :weight,        gte: 10, if: proc { |hash| hash[:contact][:name] }
        date     :birthday,      lte: Date.today
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

    casted_hash = caster.cast!(hash)
    casted_hash.object_id.should_not == hash.object_id
    caster_hash.should == hash
  end
end
