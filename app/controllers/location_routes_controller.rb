class LocationRoutesController < ApplicationController

  private
    def location_route_params
      params.require(:location_route).permit(:location_id, :route_id)
    end
end
