module FinePrint
  class ApplicationController < (controller_base_class || ActionController::Base)
    before_filter :get_user
    
    rescue_from SecurityTransgression, :with => lambda { redirect_to FinePrint.redirect_path }
    
    protected
    
    def get_user
      @user = self.send FinePrint.current_user_method
    end
  end
end
