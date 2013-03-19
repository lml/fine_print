module FinePrint
  class ApplicationController < ActionController::Base
    before_filter :get_user
    
    rescue_from SecurityTransgression, :with => lambda {
      session.delete(:fine_print_request_url)
      session.delete(:fine_print_request_referer)
      redirect_to FinePrint.redirect_path
    }
    
    protected
    
    def get_user
      @user = self.send FinePrint.current_user_method
    end
  end
end
