class BookingPolicy < ApplicationPolicy
  def index?;   user.present?; end
  def show?;    user&.admin? || record.user_id == user&.id; end
  def create?;  user.present?; end
  def cancel?;  show? && record.cancellable?; end
  def confirm?; show?; end

  class Scope < Scope
    def resolve
      user.admin? ? scope.all : scope.where(user_id: user.id)
    end
  end
end
