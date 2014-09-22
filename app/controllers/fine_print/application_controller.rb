module FinePrint
  class ApplicationController < ActionController::Base
    respond_to :html

    before_filter :get_user, :can_manage

    protected

    def get_user
      @user = instance_exec &FinePrint.current_user_proc
    end

    def can_manage
      with_interceptor { instance_exec @user, &FinePrint.can_manage_proc }
    end
  end
end
