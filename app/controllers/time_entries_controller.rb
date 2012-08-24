class TimeEntriesController < ApplicationController
  before_filter :find_entry, :only => [:edit, :update, :destroy]

  def new
    @time_entry = TimeEntry.new
  end

  def create
    @time_entry = TimeEntry.new(params[:time_entry])

    if not @time_entry.save
      flash.now[:notice] = 'Could not save the entry'
      render :action => 'new'
      return
    end

    flash[:success] = 'Entry saved'
    redirect_to user_time_entries_path(@current_user)
  end

  def edit
  end

  def update
    if @time_entry.update_attributes(params[:project])
      flash[:success] = 'Entry saved'
      redirect_to user_time_entries_path(@current_user)
    else
      flash.now[:notice] = 'Could not save the entry'
      render :action => 'edit'
  end

  def index
    @time_entries = TimeEntry.find :all
  end

  def destroy
    @time_entry.destroy

    flash[:success] = 'Entry deleted'
    redirect_to user_time_entries_path(@current_user)
  end

  protected

  def find_entry
    @time_entry = TimeEntry.find(params[:id])
  end
end
