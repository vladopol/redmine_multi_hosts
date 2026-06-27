class MultiHostSettingsController < ApplicationController

  before_action :require_admin

  def index
    @multi_hosts = MultiHost.all
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