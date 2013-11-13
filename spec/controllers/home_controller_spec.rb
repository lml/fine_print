require 'spec_helper'

module FinePrint
  describe HomeController do
    before do
      setup_controller_spec
    end

    it "won't get index unless authorized" do
      get :index, :use_route => :fine_print
      assert_response :redirect
      
      sign_in @user
      get :index, :use_route => :fine_print
      assert_response :redirect
    end
    
    it 'must get index if authorized' do
      sign_in @user
      @user.is_admin = true
      get :index, :use_route => :fine_print
      assert_response :success
    end
  end
end
