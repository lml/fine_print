module FinePrint
  module AgreementsHelper
    def fine_print_dialog
      render :partial => 'fine_print/agreements/dialog',
             :locals => {:agreements => @fine_print_dialog_agreements,
                         :user => @fine_print_user,
                         :notice => @fine_print_dialog_notice} \
      unless @fine_print_dialog_agreements.blank?
    end
  end
end
