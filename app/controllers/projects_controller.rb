class ProjectsController < ApplicationController
  before_filter :login_required
  before_filter :user_allowed_access?
  before_filter :find_project, :only => [:edit, :update, :show, :destroy]
  before_filter :confirm_user_owns_record, :only => [:edit, :update, :destroy]

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(params[:project])
    @project.user = @current_user

    if not @project.save
      flash.now[:notice] = 'Could not save the project'
      render :action => 'new'
      return
    end

    flash[:success] = 'Project saved'
    redirect_to user_projects_path(@current_user)
  end

  def edit
  end

  def update
    if @project.update_attributes(params[:project])
      flash[:success] = 'Project updated'
      redirect_to user_projects_path(@current_user)
    else
      flash.now[:notice] = 'Could not save the project'
      render :action => 'edit'
    end
  end

  def index
    @projects = Project.find(:all, :conditions => { :user_id => @current_user })
  end

  def show
  end

  def destroy
    @project.destroy

    flash[:success] = 'Project deleted'
    redirect_to user_projects_path(@current_user)
  end

  protected

  def find_project
    @project = Project.find(params[:id])
  end

  def confirm_user_owns_record
    if @project.user_id != @current_user.id
      flash[:error] = 'You\'re not allowed to go there'
      redirect_to root_path(@current_user)
    end
  end
end
