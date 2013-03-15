module FinePrint
  class ApplicationController < ActionController::Base
    before_filter :get_user
    
    rescue_from SecurityTransgression, :with => lambda { head(:forbidden) }
    
    protected
    
    def get_user
      @user = self.send FinePrint.current_user_method
    end
  end
end
