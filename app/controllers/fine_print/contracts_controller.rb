module FinePrint
  class ContractsController < FinePrint::ApplicationController
    include FinePrint::ApplicationHelper

    before_filter :get_contract, except: [:index, :new, :create]

    def index
      @contracts = Contract.includes(:signatures).all.to_a.group_by(&:name)
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
        redirect_to @contract, notice: t('fine_print.contract.notices.created')
      else
        render action: 'new', alert: merge_errors_for(@contract)
      end
    end

    def show
    end

    def edit
      @contract.no_signatures
      redirect_to contracts_path, alert: merge_errors_for(@contract) \
        unless @contract.errors.empty?
    end

    def update
      @contract.name = params[:contract][:name]
      @contract.title = params[:contract][:title]
      @contract.content = params[:contract][:content]

      if @contract.save
        redirect_to @contract, notice: t('fine_print.contract.notices.updated')
      else
        render action: 'edit', alert: merge_errors_for(@contract)
      end
    end

    def destroy
      if @contract.destroy
        redirect_to contracts_path,
                    notice: t('fine_print.contract.notices.deleted')
      else
        redirect_to contracts_path, alert: merge_errors_for(@contract)
      end
    end

    def publish
      if @contract.publish
        redirect_to contracts_path,
                    notice: t('fine_print.contract.notices.published')
      else
        redirect_to contracts_path, alert: merge_errors_for(@contract)
      end
    end

    def unpublish
      if @contract.unpublish
        redirect_to contracts_path,
                    notice: t('fine_print.contract.notices.unpublished')
      else
        redirect_to contracts_path, alert: merge_errors_for(@contract)
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
