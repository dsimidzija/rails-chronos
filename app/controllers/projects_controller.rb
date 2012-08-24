class ProjectsController < ApplicationController
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
  end

  def index
    @projects = Project.find :all
  end

  def show
  end

  def destroy
  end

end
