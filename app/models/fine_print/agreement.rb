module FinePrint
  class Agreement < ActiveRecord::Base
    attr_accessible :content, :title

    has_many :user_agreements

    before_validation :downcase_name

    validate :can_update?, on: :update

    validates_presence_of :name, :title, :content
    validates_uniqueness_of :version, :scope => :name, :case_sensitive => false

    def self.latest
      Agreement.where(is_latest: true)
    end

    def all_versions
      Agreement.where(name: self.name)
    end

    def latest
      all_versions.where(is_latest: true).first
    end

    def draft_copy
      dup.tap {|agreement| agreement.is_latest = false; agreement.version = nil}
    end

    def accepted_by?(user)
      !user.nil? && !user_agreements.where(:user_type => user.class.to_s, :user_id => user.id).empty?
    end

    def published?
      !version.nil?
    end

    def is_latest?
      is_latest
    end

    def publish
      # Set version, move 'latest' from current latest to this.  Can't publish already published

      errors.add(:base, "Cannot publish an agreement that is already published") if published?
      return false if errors.any?

      Agreement.transaction do 
        new_version = 1
        current_latest = latest

        if current_latest.present?
          new_version = current_latest.version + 1
          current_latest.is_latest = false
          current_latest.save(validate:false)
        end

        self.version = new_version
        self.is_latest = true
        self.save(validate:false)
      end
    end

    def unpublish
      # Can only unpublish latest without agreements. Clear version, remove 'is_latest'.
      # Apply is_latest to most recent published version if available.

      errors.add(:base, "Cannot unpublish a non-latest version") if !is_latest
      errors.add(:base, "Cannot unpublish an agreement that users have agreed to") if user_agreements.any?
      return false if errors.any?

      Agreement.transaction do
        last_latest_version = all_versions.where(version: self.version - 1).first

        if last_latest_version.present?
          last_latest_version.is_latest = true
          last_latest_version.save(validate:false)
        end

        self.is_latest = false
        self.version = nil
        self.save(validate:false)
      end
    end

    def can_be_read_by?(user)
      ready || FinePrint.is_admin?(user)
    end

    # def can_be_accepted_by?(user)
    #   ready && !user.nil?
    # end

    def can_be_created_by?(user)
      FinePrint.is_admin?(user)
    end

    def can_be_edited_by?(user)
      FinePrint.is_admin?(user) && user_agreements.empty?
    end

    def can_update?
      errors.add(:base, "Cannot change an agreement that users have agreed to") if user_agreements.any?
      errors.none?
    end

    def downcase_name
      self.name = name.downcase
    end

  protected


    alias_method :can_be_destroyed_by?, :can_be_edited_by?
  end
end
