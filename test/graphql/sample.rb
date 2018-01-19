# require 'test_helper'

# class MySchemaTest < ActionController::TestCase

#   u = users(:driver)
#   u.current_carpool = carpools(:carpool_2)
#   cp = current_user.current_carpool if !current_user.nil?
#   context = {
#     current_user: current_user, 
#     current_carpool: cp
#   }

# end

#   context = {}
#   variables = {}
#   result = {
#     res = MySchema.execute(
#       query_string,
#       context: context,
#       variables: variables
#     )
#     # Print any errors
#     if res["errors"]
#       pp res
#     end
#     res
#   }

#   test "a specific query" do
#     get :index
#     assert_response :success
#   end

# end



# describe MySchema do
#   # You can override `context` or `variables` in
#   # more specific scopes
#   let(:context) { {} }
#   let(:variables) { {} }
#   # Call `result` to execute the query
#   let(:result) {
#     res = MySchema.execute(
#       query_string,
#       context: context,
#       variables: variables
#     )
#     # Print any errors
#     if res["errors"]
#       pp res
#     end
#     res
#   }

#   describe "a specific query" do
#     # provide a query string for `result`
#     let(:query_string) { %|{ viewer { name } }| }

#     context "when there's no current user" do
#       it "is nil" do
#         # calling `result` executes the query
#         expect(result["data"]["viewer"]).to eq(nil)
#       end
#     end

#     context "when there's a current user" do
#       # override `context`
#       let(:context) {
#         { current_user: User.new(name: "ABC") }
#       }
#       it "shows the user's name" do
#         user_name = result["data"]["viewer"]["name"]
#         expect(user_name).to eq("ABC")
#       end
#     end
#   end
# end