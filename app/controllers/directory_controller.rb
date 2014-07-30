class DirectoryController < ApplicationController
  layout 'resource'
  include ActionView::Helpers::AssetUrlHelper # Just for assets path

  before_action :require_login

  def show
    @resource_for_angular = 'employee'
  end
end
