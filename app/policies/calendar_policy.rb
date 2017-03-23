class CalendarPolicy < ApplicationPolicy

  # https://github.com/elabs/pundit

  class Scope #< Struct.new(:user, :calendars)
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end

  end

  def calendar?
    true
  end

  # Not sure why none of this is working, maybe because there is no record associated !!!
  def index?
    true
    # (user.has_role? :admin) #|| user.has_role?(:manager, user.current_carpool)
  end

end
