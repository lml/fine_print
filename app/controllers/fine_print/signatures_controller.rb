module FinePrint
  class SignaturesController < FinePrint::ApplicationController
    include FinePrint::ApplicationHelper

    acts_as_interceptor :override_url_options => true

    skip_before_filter :can_manage, :only => [:new, :create]
    before_filter :can_sign, :only => [:new, :create]
    before_filter :get_contract, :only => [:index, :new, :create]

    def index
      @signatures = @contract.signatures
    end

    def new
      @signature = Signature.new
    end

    def create
      @signature = Signature.new

      unless params[:signature_accept]
        @signature.errors.add(:contract, t('fine_print.signature.errors.contract.must_agree'))
        render :action => 'new'
        return
      end

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
                  :notice => t('fine_print.signature.notices.deleted')
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
