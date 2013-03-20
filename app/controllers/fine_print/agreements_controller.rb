require_dependency "fine_print/application_controller"

module FinePrint
  class AgreementsController < ApplicationController
    # GET /agreements
    # GET /agreements.json
    def index
      raise SecurityTransgression unless Agreement.can_be_listed_by?(@user)
      @agreements = Agreement.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @agreements }
      end
    end
  
    # GET /agreements/1
    # GET /agreements/1.json
    def show
      @agreement = Agreement.find(params[:id])
      raise SecurityTransgression unless @agreement.can_be_read_by?(@user)
      @user_agreement = UserAgreement.new(:agreement => @agreement) if @agreement.can_be_accepted_by?(@user)
      @url = session.delete(:fine_print_request_url)
      @ref = session.delete(:fine_print_request_ref)
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @agreement }
      end
    end
  
    # GET /agreements/new
    # GET /agreements/new.json
    def new
      @agreement = Agreement.new
      raise SecurityTransgression unless @agreement.can_be_created_by?(@user)
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @agreement }
      end
    end
  
    # GET /agreements/1/edit
    def edit
      @agreement = Agreement.find(params[:id])
      raise SecurityTransgression unless @agreement.can_be_edited_by?(@user)
    end

    # GET /agreements/1/new_version
    def new_version
      @agreement = Agreement.find(params[:agreement_id]).dup
      raise SecurityTransgression unless @agreement.can_be_created_by?(@user)

      respond_to do |format|
        format.html # new_version.html.erb
        format.json { render json: @agreement }
      end
    end
  
    # POST /agreements
    # POST /agreements.json
    def create
      @agreement = Agreement.new(params[:agreement])
      raise SecurityTransgression unless @agreement.can_be_created_by?(@user)
      @agreement.version = Agreement.next_version(@agreement.name)
  
      respond_to do |format|
        if @agreement.save
          format.html { redirect_to @agreement, notice: 'Agreement was successfully created.' }
          format.json { render json: @agreement, status: :created, location: @agreement }
        else
          format.html { render action: "new" }
          format.json { render json: @agreement.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /agreements/1
    # PUT /agreements/1.json
    def update
      @agreement = Agreement.find(params[:id])
      raise SecurityTransgression unless @agreement.can_be_edited_by?(@user)
      if params[:agreement][:name].try(:downcase) != @agreement.name.downcase
        params[:agreement][:version] = Agreement.next_version(params[:agreement][:name])
      end
  
      respond_to do |format|
        if @agreement.update_attributes(params[:agreement])
          format.html { redirect_to @agreement, notice: 'Agreement was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @agreement.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /agreements/1
    # DELETE /agreements/1.json
    def destroy
      @agreement = Agreement.find(params[:id])
      raise SecurityTransgression unless @agreement.can_be_destroyed_by?(@user)
      @agreement.destroy
  
      respond_to do |format|
        format.html { redirect_to agreements_url }
        format.json { head :no_content }
      end
    end
  end
end
