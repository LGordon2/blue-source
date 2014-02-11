class Admin::TitlesController < ApplicationController
  before_action :require_login
  before_action :must_be_company_admin, except: [:sub_departments, :employees]
  before_action :set_title, only: [:show, :edit, :update, :destroy]

  # GET /titles
  # GET /titles.json
  def index
    @titles = Title.order(name: :asc)
  end

  # GET /titles/1
  # GET /titles/1.json
  def show
  end

  # GET /titles/new
  def new
    @title = Title.new
  end

  # GET /titles/1/edit
  def edit
  end

  # POST /titles
  # POST /titles.json
  def create
    @title = Title.new(title_params)

    respond_to do |format|
      if @title.save
        format.html { redirect_to admin_title_path(@title), notice: 'Title was successfully created.' }
        format.json { render action: 'show', status: :created, location: @title }
      else
        format.html { render action: 'new' }
        format.json { render json: admin_title_path(@title).errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /titles/1
  # PATCH/PUT /titles/1.json
  def update
    respond_to do |format|
      if @title.update(title_params)
        format.html { redirect_to admin_title_path(@title), notice: 'Title was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: admin_title_path(@title).errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /titles/1
  # DELETE /titles/1.json
  def destroy
    @title.destroy
    respond_to do |format|
      format.html { redirect_to admin_titles_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_title
      @title = Title.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def title_params
      params.require(:title).permit(:name)
    end
    
    def must_be_company_admin
      unless current_user.role == "Company Admin"
        redirect_to :root, flash: {error: "WTF are you doing..."}
      end
    end
end
