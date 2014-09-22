module FinePrint
  class SignaturesController < FinePrint::ApplicationController
    include FinePrint::ApplicationHelper

    skip_before_filter :can_manage, :only => [:new, :create]
    before_filter :can_sign, :only => [:new, :create]
    before_filter :get_contract, :only => [:new, :create]

    def index
      @signatures = Signature.all
    end

    def new
      @signature = Signature.new
      @signature.user = @user
      @signature.contract = @contract
    end

    def create
      @signature = Signature.new
      @signature.user = @user
      @signature.contract = @contract
  
      if @signature.save
        redirect_back
      else
        render :action => 'new', :alert => merge_errors_for(@signature)
      end
    end
  
    def destroy
      @signature = Signature.find(params[:id])

      @signature.destroy
      redirect_to contract_signatures_path(@signature.contract),
                  :notice => 'Signature was successfully deleted.'
    end

    protected

    def can_sign
      with_interceptor { instance_exec @user, &FinePrint.can_sign_proc }
    end

    def get_contract
      @contract = Contract.find(params[:contract_id])
    end
  end
end
