class OrdersController < ApplicationController

  def index
    @orders = Order.where(user_id: params[:profile_id])
  end

  def show
    @order = Order.find(params[:id])
    # binding.pry
    # @item_subtotal = Order.subtotal(params[:item])
  end

end
