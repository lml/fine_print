module FinePrint
  class ApplicationController < ActionController::Base
    respond_to :html

    before_filter :require_manager

    protected

    def require_manager
      user = FinePrint.current_user_proc.call(self)
      FinePrint.raise_security_transgression unless FinePrint.manager?(user)
    end
  end
end
