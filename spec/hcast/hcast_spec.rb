require 'spec_helper'

describe HCast do

  describe ".create" do
    it "should cast hash attributes" do
      pending
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

      caster = HCast.create do
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
          array :attendees, each: :hash do
            integer [:user_id, :contact_id], optional: true
          end
        end

        def registered?
          true
        end
      end

      casted_hash = caster.cast(input_hash)
      casted_hash.object_id.should_not == hash.object_id
      caster_hash.should == hash
    end
  end
end
