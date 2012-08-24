class ProjectsController < ApplicationController
  def new
  end

  def create
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
