require_dependency 'fine_print/application_controller'

module FinePrint
  class ContractsController < ApplicationController
    before_filter :get_contract, :except => [:index, :new, :create]

    def index
      @contracts = Contract.all
    end
  
    def show
    end

    def new
      @contract = Contract.new
    end
  
    def edit
      raise SecurityTransgression unless @contract.can_be_updated?
    end

    def new_version
      @contract = @contract.draft_copy
    end
  
    def create
      @contract = Contract.new(params[:contract])
  
      if @contract.save
        redirect_to @contract, :notice => 'Contract was successfully created.'
      else
        render :action => 'new'
      end
    end
  
    def update
      raise SecurityTransgression unless @contract.can_be_updated?

      if @contract.update_attributes(params[:contract])
        redirect_to @contract, :notice => 'Contract was successfully updated.'
      else
        render :action => 'edit'
      end
    end

    def publish
      raise SecurityTransgression unless @contract.can_be_published?

      @contract.publish
      redirect_to contracts_path, :notice => 'Contract was successfully published.'
    end

    def unpublish
      raise SecurityTransgression unless @contract.can_be_unpublished?

      @contract.unpublish
      redirect_to contracts_path, :notice => 'Contract was successfully unpublished.'
    end
  
    def destroy
      raise SecurityTransgression unless @contract.can_be_destroyed?

      @contract.destroy
      redirect_to contracts_path
    end

    protected

    def get_contract
      @contract = Contract.find(params[:id])
    end
  end
end
