class UserPolicy < ApplicationPolicy

  def user? # ???
    !@user.carpool.nil?
  end

  def index?
    (user.has_role? :admin) || (user.has_role?(:manager, user.current_carpool))
  end

  def show?
    (user.has_role? :admin) || (user.has_role?(:manager, user.current_carpool)) || (user == record)
  end

  def update?
    show?
  end

  def edit?
    show?
  end

  def destroy?
    (user.has_role? :admin) || (user == record)
  end

  def create?
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
        user.current_carpool.users.all
      # else
      # combine all members for all carpools or (as yet to be defined relationship to kids of a parent) that user manages?
        # user.manages
      # end
    end
  end

 end
