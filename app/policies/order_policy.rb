class OrderPolicy < ApplicationPolicy
  def index?  = true
  def show?   = true
  def create? = true
  def update? = owner? || staff?
end
