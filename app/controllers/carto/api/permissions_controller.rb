class Carto::Api::PermissionsController < ::Api::ApplicationController

  ssl_required :update

  def update
    permission = Carto::Permission.where(id: params[:id]).first

    return head(404) if permission.nil?
    return head(401) unless permission.is_owner?(current_user)

    begin
      acl = params[:acl]
      acl ||= []
      permission.acl = acl.map { |entry| entry.deep_symbolize_keys }
    rescue CartoDB::PermissionError => e
      CartoDB::Logger.error(exception: e)
      return head(400)
    end

    permission.save

    render json: Carto::Api::PermissionPresenter.new(permission, current_viewer: current_viewer).to_poro
  end

end
