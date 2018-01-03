class GraphqlController < ApplicationController
  
  protect_from_forgery prepend: true, with: :null_session

  def execute
    variables = ensure_hash(params[:variables])
    query = params[:query] 
    operation_name = params[:operationName]
    cp = current_user.current_carpool unless current_user.nil?
    context = {
      current_user: current_user,
      current_carpool: cp
    }
    result = CarPoolSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  end

  private

  # Handle form data, JSON body, or a blank value
  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      if ambiguous_param.present?
        ensure_hash(JSON.parse(ambiguous_param))
      else
        {}
      end
    when Hash, ActionController::Parameters
      ambiguous_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
    end
  end

  # https://blog.codeship.com/how-to-implement-a-graphql-api-in-rails/
  # def current_user
  #   return nil if request.headers['Authorization'].blank?
  #   token = request.headers['Authorization'].split(' ').last
  #   return nil if token.blank?
  #   AuthToken.verify(token)
  # end

end
