module FinePrint
  class ContractsController < FinePrint::ApplicationController
    include FinePrint::ApplicationHelper

    before_filter :get_contract, :except => [:index, :new, :create]

    def index
      @contracts = Contract.all
    end

    def new
      @contract = Contract.new
    end

    def create
      @contract = Contract.new
      @contract.name = params[:contract][:name]
      @contract.title = params[:contract][:title]
      @contract.content = params[:contract][:content]
  
      if @contract.save
        redirect_to @contract, :notice => 'Contract was successfully created.'
      else
        render :action => 'new'
      end
    end

    def show
    end

    def edit
    end

    def update
      @contract.name = params[:contract][:name]
      @contract.title = params[:contract][:title]
      @contract.content = params[:contract][:content]

      if @contract.save
        redirect_to @contract, :notice => 'Contract was successfully updated.'
      else
        render :action => 'edit'
      end
    end

    def destroy
      if @contract.destroy
        redirect_to contracts_path, :notice => 'Contract was successfully deleted.'
      else
        redirect_to contracts_path, :alert => merge_errors_for(@contract)
      end
    end

    def publish
      if @contract.publish
        redirect_to contracts_path, :notice => 'Contract was successfully published.'
      else
        redirect_to contracts_path, :alert => merge_errors_for(@contract)
      end
    end

    def unpublish
      if @contract.unpublish
        redirect_to contracts_path, :notice => 'Contract was successfully unpublished.'
      else
        redirect_to contracts_path, :alert => merge_errors_for(@contract)
      end
    end

    def new_version
      @contract = @contract.new_version
    end

    protected

    def get_contract
      @contract = Contract.find(params[:id])
    end
  end
end
