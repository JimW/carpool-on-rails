class RoutePolicy < ApplicationPolicy
    # https://github.com/elabs/pundit

  class Scope
      attr_reader :user, :scope
      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def resolve
        # if user.admin?
          # scope.all
          user.current_carpool.routes.all
        # else
        #   scope.where(:published => true)
        # end
      end
  end

  def route?
    !@user.carpool.nil?
  end

  def show?
    (user.has_role? :admin) || (user.has_role?(:manager, user.current_carpool))
  end

  def index?
    show?
  end

  def update?
    (user.has_role? :admin) || (user.has_role?(:manager, user.current_carpool))
  end

  def edit?
    (user.has_role? :admin) || (user.has_role?(:manager, user.current_carpool))
  end

  def create?
    (user.has_role? :admin) || (user.has_role?(:manager, user.current_carpool))
  end

  def destroy?
    (user.has_role? :admin) || (user.has_role?(:manager, user.current_carpool))
  end

end
