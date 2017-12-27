
# all this just to get get javascript_pack_tag inserted into the header within ActiveAdmin..
module MyApp
  module ActiveAdmin
    module Views
      module Pages
        module BaseExtension
          def build_active_admin_head
            super
            within @head do
              text_node(javascript_pack_tag('carpool-app-bundle'))
            end
          end
        end
      end
    end
  end
end
class ActiveAdmin::Views::Pages::Base < Arbre::HTML::Document
  prepend MyApp::ActiveAdmin::Views::Pages::BaseExtension
end

class MyFooter < ActiveAdmin::Component
  builder_method :footer
  def build(content)
    # para "\u00A9" + "#{Date.today.year} Jim Waterwash" # Now Causing Indonesian Translation request via Chrome on heroku, somewhere else it's doing it too !!!
    para "Copyright " + "#{Date.today.year} Jim Waterwash"
  end
end

class CustomBlankSlate < ActiveAdmin::Component
  def build(content)
    # p "content.inspect = "  + content.inspect
    # Not a great way to do this !!!
    render partial: "/admin/routes/route_calendar" if content.include? "There are no Routes"
  end
end

ActiveAdmin.setup do |config|

  # config.site_title = "dTech Carpool"
  config.site_title = ->(view) {
      # Return what you like from this lambda. Runs in the scope of the controller so you can call your helpers directly.
      # For example, I do something like:
      title = ""
      if !current_user.nil?
        if current_user.has_role?(:admin)
          title = current_user.current_carpool.organization.title_short + " Carpools: Admin"
        elsif current_user.has_role?(:manager, current_user.current_carpool)
            title = current_user.current_carpool.organization.title_short + " Carpools: Manager"
        else
          title = current_user.current_carpool.organization.title_short + " Carpools"
        end
      else
        title = "Carpools"
      end

      title += " DEV" if Rails.env.development?
      title
  }

# Show list (or dropdown of) carpools available, clicking makes it the current and reloads XXX
  # config.namespace :admin do |admin|
  #   admin.build_menu :utility_navigation do |menu|
  #     menu.add  :label  => proc{ display_name current_user.current_carpool.title_short }, # email of the current admin user logged
  #       :url            => proc { 'carpools#set-current' },
  #       :html_options   => {:style => 'float:left;'},
  #       :id             => 'current_user',
  #       :if  => proc{ current_user.is_admin? } do  |submenu|

  #           submenu.add :label => 'Custom Link', 
  #                       :url => proc { 'carpools#set-current' },
  #                       :html_options   => {:display => 'table;'} 
  #       end
  #   end
  # end

# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md JW
  # config.namespace :admin do |admin|
  #   admin.build_menu do |menu|
  #     menu.add id: 'calendar', label: proc{"Something dynamic"}, priority: 0
  #   end
  # end

  # Set the link url for the title. For example, to take
  # users to your main site. Defaults to no link.
  #
  # config.site_title_link = "/"

  # Set an optional image to be displayed for the header
  # instead of a string (overrides :site_title)
  #
  # Note: Aim for an image that's 21px high so it fits in the header.
  #
  # config.site_title_image = "logo.png"

  # == Default Namespace
  #
  # Set the default namespace each administration resource
  # will be added to.
  #
  # eg:
  #   config.default_namespace = :hello_world
  #
  # This will create resources in the HelloWorld module and
  # will namespace routes to /hello_world/*
  #

  config.view_factory.footer = MyFooter
  config.view_factory.blank_slate = CustomBlankSlate

  # To set no namespace by default, use:
    # config.default_namespace = false
  #
  # Default:
  # config.default_namespace = :admin
  #
  # You can customize the settings for each namespace by using
  # a namespace block. For example, to change the site title
  # within a namespace:
  #

  # http://stackoverflow.com/questions/14926120/active-admin-how-to-add-custom-script-before-body-tag
  # might have to actually download the source for activeadmin :(

    # config.namespace :admin do |admin|
    #
    #   # admin.site_title = "Custom Admin Title"
    #   config.view_factory.footer = Admin::AnalyticsFooter
    #
    # end

  # This will ONLY change the title for the admin section. Other
  # namespaces will continue to use the main "site_title" configuration.

  # == User Authentication
  #
  # Active Admin will automatically call an authentication
  # method in a before filter of all controller actions to
  # ensure that there is a currently logged in admin user.
  #
  # This setting changes the method which Active Admin calls
  # within the application controller.
  # config.authentication_method = :authenticate_active_admin_user!
  config.authentication_method = :authenticate_user!

  # == User Authorization
  #
  # Active Admin will automatically call an authorization
  # method in a before filter of all controller actions to
  # ensure that there is a user with proper rights. You can use
  # CanCanAdapter or make your own. Please refer to documentation.
  # config.authorization_adapter = ActiveAdmin::CanCanAdapter

  # In case you prefer Pundit over other solutions you can here pass
  # the name of default policy class. This policy will be used in every
  # case when Pundit is unable to find suitable policy.
  # config.pundit_default_policy = "MyDefaultPunditPolicy"
  # http://activeadmin.info/docs/13-authorization-adapter.html#using-the-pundit-adapter
  config.authorization_adapter = ActiveAdmin::PunditAdapter
  config.pundit_default_policy = "ApplicationPolicy"

  # You can customize your CanCan Ability class name here.
  # config.cancan_ability_class = "Ability"

  # You can specify a method to be called on unauthorized access.
  # This is necessary in order to prevent a redirect loop which happens
  # because, by default, user gets redirected to Dashboard. If user
  # doesn't have access to Dashboard, he'll end up in a redirect loop.
  # Method provided here should be defined in application_controller.rb.
  config.on_unauthorized_access = :access_denied
  # == Current User
  #
  # Active Admin will associate actions with the current
  # user performing them.
  #
  # This setting changes the method which Active Admin calls
  # (within the application controller) to return the currently logged in user.
  config.current_user_method = :current_user

  # == Logging Out
  #
  # Active Admin displays a logout link on each screen. These
  # settings configure the location and method used for the link.
  #
  # This setting changes the path where the link points to. If it's
  # a string, the strings is used as the path. If it's a Symbol, we
  # will call the method to return the path.
  #
  # Default:
  config.logout_link_path = :destroy_user_session_path

  # This setting changes the http method used when rendering the
  # link. For example :get, :delete, :put, etc..
  #
  # Default:
  config.logout_link_method = :delete
# http://codeonhill.com/devise-cancan-and-activeadmin/

  # == Root
  #
  # Set the action to call for the root path. You can set different
  # roots for each namespace.
  #
  # Default:
  # config.root_to = 'calendar#index'

  # == Admin Comments
  #
  # This allows your users to comment on any resource registered with Active Admin.
  #
  # You can completely disable comments:
  config.comments = false
  #
  # config.comments_menu = 
  #
  # You can change the name under which comments are registered:
  # config.comments_registration_name = 'AdminComment'

  # == Batch Actions
  #
  # Enable and disable Batch Actions
  #
  config.batch_actions = true

  # == Controller Filters
  #
  # You can add before, after and around filters to all of your
  # Active Admin resources and pages from here.
  #
  # config.before_action :do_something_awesome

  # == Setting a Favicon
  #
  config.favicon = 'favicon.ico'

  # == Meta Tags
  #
  # Add additional meta tags to the head element of active admin pages.
  #
  # Add tags to all pages logged in users see:
  #   config.meta_tags = { author: 'My Company' }

  # By default, sign up/sign in/recover password pages are excluded
  # from showing up in search engine results by adding a robots meta
  # tag. You can reset the hash of meta tags included in logged out
  # pages:
  #   config.meta_tags_for_logged_out_pages = {}

  # == Removing Breadcrumbs
  #
  # Breadcrumbs are enabled by default. You can customize them for individual
  # resources or you can disable them globally from here.
  #
  # config.breadcrumb = false

  # == CSV options
  #
  # Set the CSV builder separator
  # config.csv_options = { col_sep: ';' }
  #
  # Force the use of quotes
  # config.csv_options = { force_quotes: true }

  # == Menu System
  #
  # You can add a navigation menu to be used in your application, or configure a provided menu
  #
  # To change the default utility navigation to show a link to your website & a logout btn
  #
  #   config.namespace :admin do |admin|
  #     admin.build_menu :utility_navigation do |menu|
  #       menu.add label: "My Great Website", url: "http://www.mygreatwebsite.com", html_options: { target: :blank }
  #       admin.add_logout_button_to_menu menu
  #     end
  #   end
  #
  # If you wanted to add a static menu item to the default menu provided:
  #


  # == Download Links
  #
  # You can disable download links on resource listing pages,
  # or customize the formats shown per namespace/globally
  #
  # To disable/customize for the :admin namespace:
  #
    config.namespace :admin do |admin|
  #
  #     # Disable the links entirely
      admin.download_links = false
  #
  #     # Only show XML & PDF options
  #     admin.download_links = [:xml, :pdf]
  #
  #     # Enable/disable the links based on block
  #     #   (for example, with cancan)
  #     admin.download_links = proc { can?(:view_download_links) }
  #
    end

  # == Pagination
  #
  # Pagination is enabled by default for all resources.
  # You can control the default per page count for all resources here.
  #
  # config.default_per_page = 30

  # == Filters
  #
  # By default the index screen includes a "Filters" sidebar on the right
  # hand side with a filter for each attribute of the registered model.
  # You can enable or disable them for all resources here.
  #
  # config.filters = true
end
