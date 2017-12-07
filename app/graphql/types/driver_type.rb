DriverType = GraphQL::ObjectType.define do  
  interfaces [ActiveRecordInterface, User]
    
  name "Driver"
  description "A driver"

  field :driver_routes, types[RouteType] do
    resolve -> (driver, args, ctx) { driver.driver_routes.all }
  end

end