FinePrint::ApplicationController.class_eval do
  include ApplicationHelper
end

def setup_controller_spec
  class_eval { include ApplicationHelper }
  sign_out
  @user = FactoryGirl.create(:user)
  @admin = FactoryGirl.create(:user)
  @admin.is_admin = true
end
