class User < ApplicationRecord
  validates_presence_of :name, :street_address, :city, :state, :zipcode
  validates :email, presence: true, uniqueness: true
  has_many :orders
  has_many :items
  validates_presence_of :password_digest
  validates_confirmation_of :password

  has_secure_password

  enum role: ['user', 'merchant', 'admin']

  def self.all_users
    where(role: 0).order(:id)
  end

  def self.active_merchants
    where(role: 1, active: true).order(:id)
  end


  def self.all_merchants
    where(role: 1).order(:id)
  end

  def self.top_merchants_by_revenue
    joins(items: :order_items)
    .select("users.*, sum(order_items.order_price * order_items.order_quantity) as revenue")
    .where(active: true)
    .where("order_items.fulfilled = true")
    .group(:id)
    .order("revenue DESC")
    .limit(3)
  end

  def self.merchants_by_fulfillment(order = "ASC")
    joins(items: :order_items)
    .select("users.*, avg(order_items.updated_at - order_items.created_at) as fulfillment_time")
    .where(active: true)
    .where("order_items.fulfilled = true")
    .group(:id)
    .order("fulfillment_time #{order}")
    .limit(3)
  end

  def self.top_states
    joins(:orders)
    .select("users.state, count(orders.id) as total_orders")
    .where("orders.status = 2")
    .group(:state)
    .order('total_orders DESC')
    .limit(3)
  end

  def self.merchant_top_states(merchant_id)
    joins(orders: {order_items: :item})
    .select("users.state, count(orders.id) as total_orders")
    .where("items.user_id = #{merchant_id}")
    .group(:state)
    .limit(3)
    # .where("orders.status = 2")
  end

  def self.top_cities
    joins(:orders)
    .select("users.city, count(orders.id) as total_orders")
    .where("orders.status = 2")
    .group(:city)
    .order("total_orders DESC, city ASC")
    .limit(3)
  end

   def self.merchant_top_cities(merchant_id)
     joins(orders: {order_items: :item})
     .select("users.city, users.state, count(orders.id) as total_orders")
     .where("items.user_id = #{merchant_id}")
     .group("users.city, users.state")
     .order("total_orders DESC, city ASC, state ASC")
     .limit(3)
   end

    def self.top_purchaser_by_orders(merchant_id)
      joins(orders: {order_items: :item})
      .select("users.name, count(orders.id) as total_orders")
      .where("items.user_id = #{merchant_id}")
      .group("users.name")
      .order("total_orders DESC")
      .limit(1)
    end

    def self.top_purchaser_by_quantity(merchant_id)
      joins(orders: {order_items: :item})
      .select("users.name, sum(order_items.order_quantity) as total_quantity")
      .where("items.user_id = #{merchant_id}")
      .group("users.name")
      .order("total_quantity DESC")
      .limit(1)
    end

    def self.top_spenders(merchant_id)
      joins(orders: {order_items: :item})
      .select("users.name, sum(order_items.order_price) as total_spent")
      .where("items.user_id = #{merchant_id}")
      .group("users.name")
      .order("total_spent DESC")
      .limit(3)
    end

    def total_inventory
        items.sum(:inventory)
    end

end
