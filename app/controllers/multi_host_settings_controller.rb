class MultiHostSettingsController < ApplicationController

  before_action :require_admin

  def index
    @multi_hosts = MultiHost.all
  end

  def new
    @multi_host = MultiHost.new
  end

  def create
    @multi_host = MultiHost.new
    host_params = params.require(:multi_host).permit(:full_hostname, *MultiHost::EDITABLE_ATTRIBUTES)
    @multi_host.assign_attributes(host_params)
    if @multi_host.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to(action: 'index')
    else
      render :action => "new"
    end
  end

  def edit
    @multi_host = MultiHost.find(params[:id])
  end

  def update
    @multi_host = MultiHost.find(params[:id])
    host_params = params.require(:multi_host).permit(*MultiHost::EDITABLE_ATTRIBUTES)
    if @multi_host.update(host_params)
      flash[:notice] = l(:notice_successful_update)
      redirect_to(action: 'index')
    else
      render :action => "edit"
    end
  end

end
