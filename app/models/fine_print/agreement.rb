module FinePrint
  class Agreement < ActiveRecord::Base
    attr_accessible :content, :name, :version
  end
end
