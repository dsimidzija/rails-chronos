class ProjectsController < ApplicationController
  before_filter :find_project, :only => [:edit, :update, :show, :destroy]

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(params[:project])

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
    @projects = Project.find :all
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

end
