UserInterface = GraphQL::InterfaceType.define do
    
  name "UserInterface"
  description "A user"

  field :first_name, types.String
  field :last_name, types.String
  field :email, types.String
  field :can_drive, types.Boolean
  field :home_phone, types.String
  field :mobile_phone, types.String
  field :mobile_phone_messaging, types.Boolean
  field :subscribe_to_gcal, types.Boolean

end