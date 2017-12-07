LocationType = GraphQL::ObjectType.define do  
  interfaces [ActiveRecordInterface]
    
  name "Location"
  description "A location"
  
  field :title, types.String
  field :short_name, types.String # should alias this to consistent :title_short  
  field :desc, types.String

  field :latitude, types.String
  field :longitude, types.String

  field :intersect_street1, types.String
  field :intersect_street2, types.String
  field :city, types.String
  field :state, types.String

  field :routes do
    type types[RouteType]
    resolve -> (loc, args, ctx) {
      loc.routes.all
    }
  end

end