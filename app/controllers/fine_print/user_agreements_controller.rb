require_dependency "fine_print/application_controller"

module FinePrint
  class UserAgreementsController < ApplicationController

    def index
      @user_agreements = UserAgreement.all
    end
  
    def destroy
      @user_agreement = UserAgreement.find(params[:id])
      raise SecurityTransgression unless @user_agreement.can_be_destroyed_by?(@user)
      @user_agreement.destroy
      redirect_to user_agreements_url
    end

  end
end
