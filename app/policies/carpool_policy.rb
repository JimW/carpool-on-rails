class CarpoolPolicy < ApplicationPolicy
    # https://github.com/elabs/pundit

  def index?
    (user.has_role? :admin) || user.has_role?(:manager, user.current_carpool)
  end

  def show?
    scope.where(:id => record.id).exists? && (index?)
  end

  def create?
    (user.has_role? :admin) && (record.title_short != "Lobby")
  end

  def update?
    (user.has_role? :admin) || (user.has_role?(:manager, user.current_carpool) && record.title_short != "Lobby")
  end

  def destroy?
    (user.has_role? :admin)
  end

  # Unused !!!, but maybe should...
  def reset_calendar?
    (user.has_role? :admin) || user.has_role?(:manager, user.current_carpool) #|| user.carpools.includes?(carpool)
  end

  def carpool? # ???
    (@user.has_role? :admin) #|| (user.has_role?(:manager, user.current_carpool))
  end

  class Scope
    attr_reader :user, :scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end
    def resolve
      if user.is_admin?
        scope.all   # this won't work if an admin is editing on behalf of the user... !!! ??? What was I thinking here?
      else
        # scope.where(:published => true)
        user.carpools.where.not(title_short: "Lobby")# needs to actually belong to a carpool, as a driver or passenger..
      end
    end
  end

end
