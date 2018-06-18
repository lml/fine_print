FinePrint::ApplicationController.class_eval do
  include ApplicationHelper
end

def setup_controller_spec
  class_eval { include ApplicationHelper }
  sign_out
  @user = FactoryBot.create(:user)
  @admin = FactoryBot.create(:user)
  @admin.is_admin = true
end
