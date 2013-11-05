module FinePrint
  class ApplicationController < ActionController::Base
    before_filter :get_user
    before_filter :verify_admin!
    
    rescue_from FinePrint::SecurityTransgression, 
                :with => lambda { redirect_to FinePrint.redirect_path }
    
  protected
    
    def get_user
      @user = self.send FinePrint.current_user_method
    end

    def verify_admin!
      raise FinePrint::SecurityTransgression unless FinePrint.is_admin?(@user)
    end
  end
end
