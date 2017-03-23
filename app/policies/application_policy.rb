class ApplicationPolicy
  # https://github.com/elabs/pundit
  # https://github.com/activeadmin/activeadmin/blob/master/spec/support/templates/policies/application_policy.rb
  # https://github.com/elabs/pundit/blob/master/lib/generators/pundit/install/templates/application_policy.rb

  attr_reader :user, :record

  def initialize(user, record)
    # raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def show?

    if record.class.name.demodulize.eql? "Page"
      true
    else
      scope where(:id => record.id).exists?
    end

  end

  def create?
    false
  end

  def new?
    create?
  end


  def edit?
    update?
  end

  def update?
    false
  end

  def destroy?
    false
  end

  def destroy_all?
    false
  end


  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

end
