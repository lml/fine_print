require_dependency "fine_print/application_controller"

module FinePrint
  class AgreementsController < ApplicationController

    def index
      @agreements = Agreement.all
    end
  
    def show
      @agreement = Agreement.find(params[:id])
    end

    def new
      @agreement = Agreement.new
    end
  
    def edit
      @agreement = Agreement.find(params[:id])
      raise SecurityTransgression unless @agreement.can_be_edited_by?(@user)
    end

    def new_version
      @agreement = Agreement.find(params[:agreement_id]).dup
      raise SecurityTransgression unless @agreement.can_be_created_by?(@user)
    end
  
    def create
      @agreement = Agreement.new(params[:agreement])
      raise SecurityTransgression unless @agreement.can_be_created_by?(@user)
  
      if @agreement.save
        redirect_to @agreement, notice: 'Agreement was successfully created.'
      else
        render action: "new"
      end
    end
  
    def update
      @agreement = Agreement.find(params[:id])
      raise SecurityTransgression unless @agreement.can_be_edited_by?(@user)

      if @agreement.update_attributes(params[:agreement])
        redirect_to @agreement, notice: 'Agreement was successfully updated.'
      else
        render action: "edit"
      end
    end
  
    def destroy
      @agreement = Agreement.find(params[:id])
      raise SecurityTransgression unless @agreement.can_be_destroyed_by?(@user)
      @agreement.destroy
      redirect_to agreements_url
    end

  end
end
