
  # RouteCategoryEnum = GraphQL::EnumType.define do
  #   name "Route Category"
  #   value("TEMPLATE",    "template",    value: 0)
  #   value("INSTANCE",   "instance",   value: 1)
  #   value("MODIFIED_INSTANCE", "modified_instance", value: 2)
  #   value("SPECIAL",  "special",  value: 3)
  # end

RouteType = GraphQL::ObjectType.define do  
  interfaces [ActiveRecordInterface]
    
  name "Route"
  description "A route"
  
  field :title, types.String # this is constructed within model.. why not do it here or somewhere Graphqlish..?
  
  field :description, types.String
  field :completed, types.Boolean
  field :seq, types.Int
  field :passenger_cnt, types.Int

  field :category, types.String 
  # field :category, RouteCategoryEnum 
  # https://github.com/apollographql/core-docs/issues/178

  field :starts_at, types.String
  field :ends_at, types.String
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
  field :event do
    type EventType
    resolve -> (route, args, ctx) {
      route.event
    }
  end


  # DayOfTheWeekEnum = GraphQL::EnumType.define do
  #     name "Day of the week"
  #     value("MONDAY",    "Monday",    value: 1)
  #     value("TUESDAY",   "Tuesday",   value: 2)
  #     value("WEDNESDAY", "Wednesday", value: 3)
  #     value("THURSDAY",  "Thursday",  value: 4)
  #     value("FRIDAY",    "Friday",    value: 5)
  #     value("SATURDAY",  "Saturday",  value: 6)
  #     value("SUNDAY",    "Sunday",    value: 0)
  # end

end