class TimeEntriesController < ApplicationController
  before_filter :login_required
  before_filter :user_allowed_access?
  before_filter :find_entry, :only => [:edit, :update, :destroy]
  before_filter :confirm_user_owns_record, :only => [:edit, :update, :destroy]

  def new
    @time_entry = TimeEntry.new
  end

  def create
    @time_entry = TimeEntry.new(params[:time_entry])
    @time_entry.user = @current_user

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
    if @time_entry.update_attributes(params[:time_entry])
      flash[:success] = 'Entry saved'
      redirect_to user_time_entries_path(@current_user)
    else
      flash.now[:notice] = 'Could not save the entry'
      render :action => 'edit'
    end
  end

  def index
    @time_entries = TimeEntry.where(:user_id => @current_user)
      .paginate(:page => params[:page])
      .order('entry_date DESC, start_time DESC')
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

  def confirm_user_owns_record
    if @time_entry.user_id != @current_user.id
      flash[:error] = 'You\'re not allowed to go there'
      redirect_to user_time_entries_path(@current_user)
    end
  end
end
