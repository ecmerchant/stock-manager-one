class ItemsController < ApplicationController
  def show
    @item = Item.find_by(user: current_user.email)
    @search = SearchCondition.find_by(user: current_user.email)
    if @item == nil then
      @item = Item.new
    end
    if @search == nil then
      @search = SearchCondition.new
    end
  end

  def search
  end
end
