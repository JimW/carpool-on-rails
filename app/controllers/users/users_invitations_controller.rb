# Note: I abandoned the idea of even involving the partipants in using the system, so this is not needed at this point

# # /app/controllers/users_invitations_controller.rb
#
# class UsersInvitationsController < Devise::InvitationsController
#
#    # GET /resource/invitation/accept?invitation_token=abcdef
#   def edit
#     render :edit, :layout => false
#   end
#
#   # PUT /resource/invitation
#   def update
#     self.resource = resource_class.accept_invitation!(resource_params)
#
#     if resource.errors.empty?
#       flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
#       set_flash_message :notice, flash_message
#       sign_in(resource_name, resource)
#
#       redirect_to '/profile', :alert => "Welcome! Please fill out your profile"
#     else
#       respond_with_navigational(resource){ render :edit, :layout => false }
#     end
#   end
# end
