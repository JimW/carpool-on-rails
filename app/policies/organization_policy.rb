class OrganizationPolicy < ApplicationPolicy

    # https://github.com/elabs/pundit

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      # if user.admin?
        scope.all
      # else
      #   scope.where(:published => true)
      # end
    end
  end

  def show?
    @user.has_role? :admin
  end

  def carpool?
    @user.has_role? :admin
  end

  def index?
    (user.has_role? :admin) #|| user.has_role?(:manager, user.current_carpool)
  end

  def create?
    (user.has_role? :admin)
  end

  def update?
    (user.has_role? :admin) #|| user.has_role?(:manager, user.current_carpool) #|| user.carpools.includes?(carpool)
  end

  def destroy?
    (user.has_role? :admin)
  end

end
