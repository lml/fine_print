module FinePrint
  class ApplicationController < ActionController::Base
    before_filter :verify_admin

    rescue_from FinePrint::SecurityTransgression, 
                :with => lambda { redirect_to FinePrint.redirect_path }

    protected

    def verify_admin
      user = send FinePrint.current_user_method
      FinePrint.raise_unless_admin(user)
    end
  end
end
