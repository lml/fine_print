module FinePrint
  class ApplicationController < ActionController::Base
    before_filter :require_manager

    protected

    def require_manager
      user = FinePrint.current_user_proc.call(self)
      raise IllegalState, 'User is not a manager' unless FinePrint.manager?(user)
    end
  end
end
