module FinePrint
  class Agreement < ActiveRecord::Base
    attr_accessible :name, :content

    has_many :user_agreements

    validates_presence_of :name, :content, :version

    default_scope order(:name, :version)

    def self.can_be_listed_by?(user)
      FinePrint.is_admin?(user)
    end

    def can_be_created_by?(user)
      FinePrint.is_admin?(user)
    end

    def can_be_edited_by?(user)
      FinePrint.is_admin?(user) && user_agreements.empty?
    end

    alias_method :can_be_destroyed_by?, :can_be_edited_by?
  end
end
