RouteType = GraphQL::ObjectType.define do  
  interfaces [ActiveRecordInterface]
    
  name "Route"
  description "A route"
  
  field :title, types.String # this is constructed within model.. why not do it here or somewhere Graphqlish..?
  
  field :description, types.String
  field :completed, types.Boolean
  field :seq, types.Int
  field :passenger_cnt, types.Int
  field :description, types.String
  field :category, types.Int
  field :starts_at, types.Int
  field :ends_at, types.Int
  field :modified, types.Boolean

  field :carpool do
    type CarpoolType
    resolve -> (route, args, ctx) {
      route.carpool
    }
  end
  field :passengers do
    type types[UserType]
    resolve -> (route, args, ctx) {
      route.passengers.all
    }
  end
  field :drivers do
    type types[UserType]
    resolve -> (route, args, ctx) {
      route.drivers.all
    }
  end
  field :locations do
    type types[LocationType]
    resolve -> (route, args, ctx) {
      route.locations.all
    }
  end

  #field :event do
  # XXX How can I suck in the has_one relationship of Events.. This can eliminate the need for 
  # the Route.get_events, having it format specically for fullcalendr.  
  # Makes more sense to move that kind of stuff to graphql layer, plus the events could be more
  # intelligently cached there.
end