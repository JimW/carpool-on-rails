CarpoolType = GraphQL::ObjectType.define do  
  interfaces [ActiveRecordInterface]
    
  name "Carpool"
  description "A carpool"

  field :title, types.String
  field :title_short, types.String
  
  field :users do
    type types[UserType]
    argument :only_active, types.Boolean, default_value: false
    resolve -> (carpool, args, ctx) {
      if args[:only_active] then
        carpool.active_users
      else
        carpool.users
      end     
    }
  end

  field :passengers do
    type types[UserType]
    argument :only_active, types.Boolean, default_value: false    
    resolve -> (carpool, args, ctx) {
      if args[:only_active] then
        carpool.active_passengers
      else
        carpool.passengers
      end     
    }
  end

  field :drivers do
    type types[UserType]
    argument :only_active, types.Boolean, default_value: false    
    resolve -> (carpool, args, ctx) {
      if args[:only_active] then
        carpool.active_drivers
      else
        carpool.drivers
      end        
    }
  end

  field :routes do
    type types[RouteType]
    # argument :size, types.Int, default_value: 10    
    resolve -> (carpool, args, ctx) {
      carpool.routes#.limit(args[:size])
    }
  end
end