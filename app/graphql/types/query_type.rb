Types::QueryType = GraphQL::ObjectType.define do
  name "Query"
  # Add root-level fields here.
  # They will be entry points for queries on your schema.
  
  field :viewer do
    type UserType
    description "Current user"
    resolve ->(obj, args, ctx) {
      ctx[:current_user]
    }
  end

  field :carpool do
    type CarpoolType
    resolve -> (obj, args, ctx) {
      argument :id, !types.ID      
      Carpool.find(args[:id])
    }
  end

  field :user do
    type UserType
    argument :id, !types.ID
    resolve -> (obj, args, ctx) {
      User.find(args[:id])
    }
  end

  field :users, types[UserType] do
    resolve -> (obj, args, ctx) { User.all }
  end
  
  field :fc_events do
    type types.String 
    argument :cat_type, !types.String
    resolve -> (obj, args, ctx) {
      Route.get_events(args[:cat_type])
    }
  end

  field :fc_eventSources do
    type types.String 
    resolve -> (obj, args, ctx) {

      eventSources = [
        {events: Route.events_of_category("instance")},
        {events: Route.events_of_category("modified_instance")},
        {events: Route.events_of_category("special")},
      ]
      eventSources.to_json
    }
  end

  field :routes do
    type types[RouteType] 
    argument :cat_type, !types.String
    resolve -> (obj, args, ctx) {
      Route.of_category(args[:cat_type])
    }
  end

  # field :drivers do
  #   type types[DriverType]
  #   description "User that can drive"
  #   resolve ->(obj, args, ctx) {
  #     current_user = ctx[:current_user]
  #     current_user.current_carpool.drivers
  #   }
  # end

end
