class MenuItemPolicy < ApplicationPolicy
  def index?   = true
  def show?    = true
  def search?  = true
  def create?  = owner? || staff?
  def update?  = owner? || staff?
  def destroy? = owner? || staff?
end
