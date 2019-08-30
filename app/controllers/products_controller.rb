class ProductsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]
  def new
    @product = Product.new
    @product.images.build
    @parents = Category.all.order("id ASC").limit(13)

    @category_parent_array = ["---"]
    #データベースから、親カテゴリーのみ抽出し、配列化
    Category.where(ancestry: nil).each do |parent|
      @category_parent_array << parent.name
    end
  end
  
  # 親カテゴリーが選択された後に動くアクション
  def get_category_children
    #選択された親カテゴリーに紐付く子カテゴリーの配列を取得
    @category_children = Category.find_by(name: "#{params[:parent_name]}", ancestry: nil).children
  end

  # 子カテゴリーが選択された後に動くアクション
  def get_category_grandchildren
  #選択された子カテゴリーに紐付く孫カテゴリーの配列を取得
    @category_grandchildren = Category.find("#{params[:child_id]}").children
  end

  def create
    @product = Product.new(product_params)
    @product.user_id = current_user.id
    if @product.valid?
      if @product.save!
      else
        redirect_to new_product_path
      end
    else
      @messages = @product.errors.full_messages
      flash[:error] = []
      @messages.each do |message|
        flash[:error] << message
      end
      redirect_to new_product_path
    end
    
  end

  def edit
    @product = Product.find(params[:id])
    # @images = @product.images
    @parents = Category.all.order("id ASC").limit(13)
  end

  def update
    @product = Product.find(params[:id])
    # @images = @product.images
    if @product.update(product_params)
      # params[:images][:image].each do |image|
      #   @product.images.update(image: image, product_id: @product.id)
        redirect_to root_path
      # end
    else
      redirect_to new_product_path
    end
  end
    
  def index
    @ledies = Product.ransack(category_ancestry_start: "1/").result.order(id: :desc).limit(4)
    @mens = Product.ransack(category_ancestry_start: "2/").result.order(id: :desc).limit(4)
    @kids = Product.ransack(category_ancestry_start: "3/").result.order(id: :desc).limit(4)
    @cosme = Product.ransack(category_ancestry_start: "7/").result.order(id: :desc).limit(4)
    @syanera = Product.ransack(brand_cont: "シャネラ").result.order(id: :desc).limit(4)
    @ruibiton = Product.ransack(brand_cont: "ルイビトン").result.order(id: :desc).limit(4)
    @syupurinmu = Product.ransack(brand_cont: "シュプリンム").result.order(id: :desc).limit(4)
    @naiko = Product.ransack(brand_cont: "ナイコ").result.order(id: :desc).limit(4)
  end
  
  def show
    @product = Product.find(params[:id])
    @first_product=Product.first
    @last_product=Product.last
    @same_category_products = Product.where(category_id: @product.category_id).where.not(id:@product.id).order('created_at DESC').limit(6)
    @category=Category.all
    @other_products = @product.user.products.where.not(id: @product.id)
  end

  def search
    if params[:q].present?
      @search = Product.ransack(search_params)
      @products = @search.result.page(params[:page]).per(132).order(id: :desc)
      @products0 = Product.all.limit(24).order(id: :desc)
    else
      params[:q] = { sorts: 'id desc' }
      @search = Product.ransack()
      @products = Product.page(params[:page]).per(132).order(id: :desc)
    end
  end

  def delete
    product = Product.find(params[:id])
      if product.user_id == current_user.id
        product.destroy
      end
  end

  def destroy
    product = Product.find(params[:id])
      if product.user_id == current_user.id
        product.destroy
      end
    redirect_to root_path
  end
  
  private

  def product_params
    params.require(:product).permit(:name,:detail,:user_id,:size_id,:brand,:condition_id,:delivery_fee_id,:shipping_method_id,:prefecture_from_id,:shipping_days_id,:price,:status,:category_id,images_attributes: [:image, :id,:_destroy])
  end

  
  def search_params
    params.require(:q).permit!
  end
end


