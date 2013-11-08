module FinePrint
  class SignaturesController < FinePrint::ApplicationController
    def index
      @signatures = Signature.all
    end
  
    def destroy
      @signature = Signature.find(params[:id])

      @signature.destroy
      redirect_to signatures_url
    end
  end
end
