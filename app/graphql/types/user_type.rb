UserType = GraphQL::ObjectType.define do  
  interfaces [ActiveRecordInterface, UserInterface]
    
  name "User"
  description "A user"

  field :carpools do
    type types[CarpoolType]
    argument :size, types.Int, default_value: 10
    resolve -> (user, args, ctx) {
      user.carpools.limit(args[:size])
    }
  end

  field :organizations do
    type types[OrganizationType]
    resolve -> (user, args, ctx) {
      user.organizations
    }
  end
end