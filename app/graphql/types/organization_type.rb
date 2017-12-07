OrganizationType = GraphQL::ObjectType.define do  
  interfaces [ActiveRecordInterface]
    
  name "Organization"
  description "An organization containing multiple carpools"

  field :title, types.String
  field :title_short, types.String
  field :description, types.String
  
  field :carpools do
    type types[CarpoolType]
    resolve -> (org, args, ctx) {
      org.carpools
    }
  end

end