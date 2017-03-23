class LocationPolicy < ApplicationPolicy
    # https://github.com/elabs/pundit

    def location? # ???
      !user.carpool.nil?
    end

    def index?
      (user.has_role? :admin) || (user.has_role?(:manager, user.current_carpool)) #|| (user.has_role?(:manager, user.current_carpool)) 
    end

    def create?
      (user.has_role? :admin) || (user.has_role?(:manager, user.current_carpool))
    end

    def show?
      create?
    end

    def new?
      create?
    end

    def edit?
      create?
    end

    def update?
      create?
    end

    def destroy?
      create?
    end

    def destroy_all?
      create?
    end

    def update?
      (user.has_role? :admin) || (user.has_role?(:manager, user.current_carpool))
    end

    class Scope
      attr_reader :user, :scope
      def initialize(user, scope)
        @user = user
        @scope = scope
      end
      def resolve
        # if user.is_admin?
        #   scope.all
        # else
          user.current_carpool.locations.all
        # else
        # combine all locations for all carpools that user manages?
          # user.manages
        # end
      end
    end

 end
