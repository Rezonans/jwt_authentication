class JwtAuthentication::PasswordsController < Devise::PasswordsController
  include JwtAuthentication::Concerns::JwtControllerHelpers

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?
    if resource.errors.empty?
      render nothing: true, status: json_status(true)
    else
      render_errors resource.errors
    end
  end

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?
    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      sign_in(resource_name, resource)
      token, expires = resource.jwt_token_and_expires
      send(:"set_jwt_cookie_for_#{resource_name}", token, expires)
      render json: { auth_token: token, resource: resource }
    else
      render_errors resource.errors
    end
  end
end
