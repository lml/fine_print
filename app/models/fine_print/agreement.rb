module FinePrint
  class Agreement < ActiveRecord::Base
    attr_accessible :name, :content

    has_many :user_agreements

    validates_presence_of :name, :content, :version

    default_scope order(:name, :version)

    def can_be_edited?
      user_agreements.empty?
    end

    alias_method :can_be_destroyed?, :can_be_edited?
  end
end
