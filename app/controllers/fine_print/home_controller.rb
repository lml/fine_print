require_dependency "fine_print/application_controller"

module FinePrint
  class HomeController < ApplicationController
    # GET /fine_print
    def index
      raise SecurityTransgression unless Agreement.can_be_listed_by?(@user) && UserAgreement.can_be_listed_by?(@user)
  
      respond_to do |format|
        format.html # index.html.erb
      end
    end
  end
end
