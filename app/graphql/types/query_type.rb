Types::QueryType = GraphQL::ObjectType.define do
  name "Query"
  # Add root-level fields here.
  # They will be entry points for queries on your schema.
  
  field :viewer do
    type UserType
    description "Current user"
    resolve ->(obj, args, ctx) {
      if ctx[:current_user].blank?
        raise GraphQL::ExecutionError.new("Authentication required")
      end
      ctx[:current_user]
    }
  end

  field :carpool do
    type CarpoolType
    resolve -> (obj, args, ctx) {
      if ctx[:current_user].blank?
        raise GraphQL::ExecutionError.new("Authentication required")
      end
      argument :id, !types.ID      
      Carpool.find(args[:id])
    }
  end

  field :user do
    type UserType
    argument :id, !types.ID
    resolve -> (obj, args, ctx) {
      if ctx[:current_user].blank?
        raise GraphQL::ExecutionError.new("Authentication required")
      end
      User.find(args[:id])
    }
  end

  field :allUsers, types[UserType] do
    resolve -> (obj, args, ctx) { 
      if ctx[:current_user].blank?
        raise GraphQL::ExecutionError.new("Authentication required")
      end
      User.all 
    }
  end

  field :currentUser do
    type UserType 
    resolve -> (obj, args, ctx) {
      if ctx[:current_user].blank?
        raise GraphQL::ExecutionError.new("Authentication required")
      end
      ctx[:current_user]
    }
  end

  field :fcEventSources do
    type types.String 
    resolve -> (obj, args, ctx) {
      if ctx[:current_user].blank?
        raise GraphQL::ExecutionError.new("Authentication required")
      end
      cp = ctx[:current_carpool]
      eventSources = [
        {events: cp.routes.of_category("instance").all_events()},
        {events: cp.routes.of_category("modified_instance").all_events()},
        {events: cp.routes.of_category("special").all_events()},
      ]
      eventSources.to_json
    }
  end

  field :all_routes do
    type types[RouteType] 
    resolve -> (obj, args, ctx) {
      if ctx[:current_user].blank?
        raise GraphQL::ExecutionError.new("Authentication required")
      end
      cp = ctx[:current_carpool]
      cp.routes
    }
  end

end
