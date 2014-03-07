module FinePrint
  class ApplicationController < ActionController::Base
    before_filter :verify_admin

    protected

    def verify_admin
      user = FinePrint.current_user_proc.call(self)
      FinePrint.raise_unless_admin(user)
    end
  end
end
