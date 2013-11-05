require_dependency "fine_print/application_controller"

module FinePrint
  class ContractsController < ApplicationController

    before_filter :get_contract, only: [:show, :edit, :new_version, :update, :destroy, :publish, :unpublish]

    def index
      @contracts = Contract.all
    end
  
    def show
    end

    def new
      @contract = Contract.new
    end
  
    def edit
      raise SecurityTransgression unless @contract.can_be_edited_by?(@user)
    end

    def new_version
      @contract = @contract.draft_copy
      raise SecurityTransgression unless @contract.can_be_created_by?(@user)
    end
  
    def create
      @contract = Contract.new(params[:contract])
      raise SecurityTransgression unless @contract.can_be_created_by?(@user)
  
      if @contract.save
        redirect_to @contract, notice: 'Contract was successfully created.'
      else
        render action: "new"
      end
    end
  
    def update
      raise SecurityTransgression unless @contract.can_be_edited_by?(@user)

      if @contract.update_attributes(params[:contract])
        redirect_to @contract, notice: 'Contract was successfully updated.'
      else
        render action: "edit"
      end
    end

    def publish
      @contract.publish
      redirect_to request.referrer
    end

    def unpublish
      @contract.unpublish
      redirect_to request.referrer
    end
  
    def destroy
      raise SecurityTransgression unless @contract.can_be_destroyed_by?(@user)
      @contract.destroy
      redirect_to contracts_url
    end

  protected

    def get_contract
      @contract = Contract.find(params[:id] || params[:contract_id])
    end

  end
end
