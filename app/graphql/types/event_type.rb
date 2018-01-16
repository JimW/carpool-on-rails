EventType = GraphQL::ObjectType.define do  
  interfaces [ActiveRecordInterface]
    
  name "Event"
  description "An event"

  field :title, types.String # this is constructed within model.. why not do it here or somewhere Graphqlish..?
  field :starttime, types.String
  field :endtime, types.String
  field :all_day, types.Boolean
  field :description, types.String # this is constructed within model.. why not do it here or somewhere Graphqlish..?
  field :event_series_id, types.Int # garbage, redo this EventEngine garbage carryover

end