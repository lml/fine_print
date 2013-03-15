require_dependency "fine_print/application_controller"

module FinePrint
  class UserAgreementsController < ApplicationController
    # GET /user_agreements
    # GET /user_agreements.json
    def index
      raise SecurityTransgression unless UserAgreement.can_be_listed_by?(@user)
      @user_agreements = UserAgreement.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @user_agreements }
      end
    end
  
    # POST /user_agreements
    # POST /user_agreements.json
    def create
      @user_agreement = UserAgreement.new(params[:user_agreement])
  
      respond_to do |format|
        if @user_agreement.save
          format.html { redirect_to @user_agreement, notice: 'User agreement was successfully created.' }
          format.json { render json: @user_agreement, status: :created, location: @user_agreement }
        else
          format.html { render action: "new" }
          format.json { render json: @user_agreement.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /user_agreements/1
    # DELETE /user_agreements/1.json
    def destroy
      @user_agreement = UserAgreement.find(params[:id])
      raise SecurityTransgression unless @user_agreement.can_be_destroyed_by?(@user)
      @user_agreement.destroy
  
      respond_to do |format|
        format.html { redirect_to user_agreements_url }
        format.json { head :no_content }
      end
    end
  end
end
