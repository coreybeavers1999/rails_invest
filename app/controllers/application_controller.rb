class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  layout :layout_by_controller


  # If on a devise route, force the welcome layout
  def layout_by_controller
    return "welcome" if devise_controller?

    # Return nothing for default layout behavior
  end

end
