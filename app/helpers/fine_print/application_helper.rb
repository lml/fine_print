module FinePrint
  module ApplicationHelper
    def merge_errors_for(obj)
      "#{obj.errors.collect{|f,e| "#{e}"}.join('. ')}."
    end
  end
end
