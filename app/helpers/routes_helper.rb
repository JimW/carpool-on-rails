# app/helpers/route_helper.rb
module RoutesHelper

  def my_formatted_number number
    number_to_currency(number, separator: ",", delimiter: "", format: '%n')
  end
  
end
