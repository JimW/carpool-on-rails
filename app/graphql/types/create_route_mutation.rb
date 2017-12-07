CreateRouteMutation = GraphQL::Relay::Mutation.define do
  # ...

  resolve -> (object, inputs, ctx) {
    Graph::CreateRouteService.new(inputs, ctx).perform!
  }
end