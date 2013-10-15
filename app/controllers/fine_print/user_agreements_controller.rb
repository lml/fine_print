require_dependency "fine_print/application_controller"

module FinePrint
  class UserAgreementsController < ApplicationController

    def index
      @user_agreements = UserAgreement.all
    end
  
    def create
      @agreement = Agreement.find(params[:agreement_id])
      raise SecurityTransgression unless @agreement.can_be_accepted_by?(@user)

      if params[:cancel] || (@agreement.display_confirmation && !params[:confirmation_checkbox])
        respond_to do |format|
          format.html { redirect_to params[:ref] || FinePrint.get_option(params, :cancel_path) }
          format.js { render 'cancel' }
        end
        return
      end

      @index = params[:index].to_i
      @user_agreement = UserAgreement.new
      @user_agreement.agreement = @agreement
      @user_agreement.user = @user
      redirect_path = params[:url] || FinePrint.get_option(params, :accept_path)
  
      respond_to do |format|
        if @user_agreement.save
          format.html { redirect_to redirect_path, notice: "#{@user_agreement.agreement.name} accepted." }
          format.json { render json: @user_agreement, status: :created, location: @user_agreement }
          format.js
        else
          format.html { redirect_to redirect_path, notice: "You have already accepted this agreement." }
          format.json { render json: @user_agreement.errors, status: :unprocessable_entity }
          format.js { redirect_to redirect_path, notice: "You have already accepted this agreement." }
        end
      end
    end
  
    def destroy
      @user_agreement = UserAgreement.find(params[:id])
      raise SecurityTransgression unless @user_agreement.can_be_destroyed_by?(@user)
      @user_agreement.destroy
      redirect_to user_agreements_url
    end

  end
end
