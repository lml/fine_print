require_dependency "fine_print/application_controller"

module FinePrint
  class UserAgreementsController < ApplicationController
    # GET /user_agreements
    # GET /user_agreements.json
    def index
      @user_agreements = UserAgreement.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @user_agreements }
      end
    end
  
    # GET /user_agreements/1
    # GET /user_agreements/1.json
    def show
      @user_agreement = UserAgreement.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @user_agreement }
      end
    end
  
    # GET /user_agreements/new
    # GET /user_agreements/new.json
    def new
      @user_agreement = UserAgreement.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @user_agreement }
      end
    end
  
    # GET /user_agreements/1/edit
    def edit
      @user_agreement = UserAgreement.find(params[:id])
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
  
    # PUT /user_agreements/1
    # PUT /user_agreements/1.json
    def update
      @user_agreement = UserAgreement.find(params[:id])
  
      respond_to do |format|
        if @user_agreement.update_attributes(params[:user_agreement])
          format.html { redirect_to @user_agreement, notice: 'User agreement was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @user_agreement.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /user_agreements/1
    # DELETE /user_agreements/1.json
    def destroy
      @user_agreement = UserAgreement.find(params[:id])
      @user_agreement.destroy
  
      respond_to do |format|
        format.html { redirect_to user_agreements_url }
        format.json { head :no_content }
      end
    end
  end
end
