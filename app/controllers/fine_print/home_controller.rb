module FinePrint
  class HomeController < FinePrint::ApplicationController

    def index
      redirect_to contracts_path
    end

  end
end
