CarPoolSchema = GraphQL::Schema.define do
  mutation(Types::MutationType)
  query(Types::QueryType)

  resolve_type ->(type, obj, ctx) { 
    # case obj
    # when Post
    #   Types::PostType
    # when Comment
    #   Types::CommentType
    # else
    #   raise("Unexpected object: #{obj}")
    # end
   }

  # Maybe useful for feeding google a better UUID XXX
  #  https://github.com/rmosolgo/graphql-ruby/blob/master/guides/relay/object_identification.md
  # id_from_object ->(object, type_definition, query_ctx) {
  #   # Call your application's UUID method here
  #   # It should return a string
  #   MyApp::GlobalId.encrypt(object.class.name, object.id)
  # }
  # object_from_id ->(id, query_ctx) {
  #   class_name, item_id = MyApp::GlobalId.decrypt(id)
  #   # "Post" => Post.find(id)
  #   Object.const_get(class_name).find(item_id)
  # }

  #                            or

  # # Create UUIDs by joining the type name & ID, then base64-encoding it
  # id_from_object ->(object, type_definition, query_ctx) {
  #   GraphQL::Schema::UniqueWithinType.encode(type_definition.name, object.id)
  # }
  # object_from_id ->(id, query_ctx) {
  #   type_name, item_id = GraphQL::Schema::UniqueWithinType.decode(id)
  #   # Now, based on `type_name` and `id`
  #   # find an object in your application
  #   # ....
  # }


end
