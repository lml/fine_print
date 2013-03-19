module FinePrint
  class Agreement < ActiveRecord::Base
    attr_accessible :name, :version, :content, :confirmation_text, :display_name, :display_version, :display_updated, :display_confirmation, :ready

    has_many :user_agreements

    validates_presence_of :name, :content, :version
    validates_uniqueness_of :name, :scope => :version, :case_sensitive => false

    default_scope order(:name, :version)

    def self.latest(name)
      find(:last, :conditions => ["LOWER(name) = ?", name.try(:downcase)])
    end

    def self.next_version(name)
      (latest(name).try(:version) || 0) + 1
    end

    def self.latest_ready(name)
      where(:ready => true).find(:last, :conditions => ["LOWER(name) = ?", name.try(:downcase)])
    end

    def accepted_by?(user)
      !user.nil? && !user_agreements.where(:user_type => user.class.to_s, :user_id => user.id).empty?
    end

    def self.can_be_listed_by?(user)
      FinePrint.is_admin?(user)
    end

    def can_be_read_by?(user)
      ready || FinePrint.is_admin?(user)
    end

    def can_be_accepted_by?(user)
      ready && !user.nil?
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
