require_dependency "fine_print/application_controller"

module FinePrint
  class AgreementsController < ApplicationController

    before_filter :get_agreement, only: [:show, :edit, :new_version, :update, :destroy, :publish, :unpublish]

    def index
      @agreements = Agreement.all
    end
  
    def show
    end

    def new
      @agreement = Agreement.new
    end
  
    def edit
      raise SecurityTransgression unless @agreement.can_be_edited_by?(@user)
    end

    def new_version
      @agreement = @agreement.draft_copy
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
      raise SecurityTransgression unless @agreement.can_be_edited_by?(@user)

      if @agreement.update_attributes(params[:agreement])
        redirect_to @agreement, notice: 'Agreement was successfully updated.'
      else
        render action: "edit"
      end
    end

    def publish
      @agreement.publish
      redirect_to request.referrer
    end

    def unpublish
      @agreement.unpublish
      redirect_to request.referrer
    end

    def agree(user)
      UserAgreement.create(user: user, agreement: self)
    end
  
    def destroy
      raise SecurityTransgression unless @agreement.can_be_destroyed_by?(@user)
      @agreement.destroy
      redirect_to agreements_url
    end

  protected

    def get_agreement
      @agreement = Agreement.find(params[:id] || params[:agreement_id])
    end

  end
end
