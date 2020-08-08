class Ckeditor::PicturesController < Ckeditor::ApplicationController
  skip_before_filter :verify_authenticity_token, only: :create

  def index
    order_query = { :order => [:created_at, :desc] }
    order_query = { :order => [:created_at, :asc] } if params[:desc] == "0"
    order_query = { website_id: @website.id} if @website.present?
    params.delete :query if params[:desc].present?
    params.delete :date if params[:desc].present?
    params.delete :commit if params[:commit].present?
    @pictures = Ckeditor.picture_adapter.find_all(order_query)
    @pictures = @pictures.where("data_file_name LIKE ?", "%#{params[:query]}%") if params[:query].present?
    @pictures = @pictures.where("created_at <= ?", params[:date]) if params[:date].present?
    @pictures = Ckeditor::Paginatable.new(@pictures).page(params[:page])

    respond_to do |format|
      format.html { render :layout => @pictures.first_page? }
    end
  end

  def create
    @picture = Ckeditor.picture_model.new(website_id: @website.id) if @website.present?
    respond_with_asset(@picture)
  end

  def destroy
    @picture.destroy

    respond_to do |format|
      format.html { redirect_to pictures_path }
      format.json { render :nothing => true, :status => 204 }
    end
  end

  protected

    def find_asset
      @picture = Ckeditor.picture_adapter.get!(params[:id])
    end

    def authorize_resource
      model = (@picture || Ckeditor.picture_model)
      @authorization_adapter.try(:authorize, params[:action], model)
    end
end
