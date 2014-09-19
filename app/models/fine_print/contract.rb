module FinePrint
  class Contract < ActiveRecord::Base
    has_many :signatures, :dependent => :destroy, :inverse_of => :contract

    has_many :same_name, :class_name => 'Contract',
             :primary_key => :name, :foreign_key => :name

    before_validation :downcase_name
    before_update :no_signatures
    before_destroy :no_signatures

    validates :name, :presence => true, :format => /\A[\w-]+\z/
    validates :title, :presence => true
    validates :content, :presence => true
    validates :version, :uniqueness => {:scope => :name, :case_sensitive => false}

    default_scope lambda { order{[name.asc, version.desc]} }

    scope :published, lambda { where{version != nil} }
    scope :latest, lambda { joins(:same_name).group{id}
                              .having{version == max(same_name.version)} }

    def is_published?
      !version.nil?
    end

    def is_latest?
      is_published? && self == same_name.published.first
    end

    def publish
      errors.add(:base, 'Contract is already published') if is_published?
      return false unless errors.empty?

      self.version = (same_name.published.first.try(:version) || 0) + 1
      save
    end

    def unpublish
      no_signatures
      errors.add(:base, 'Contract is not the latest published version') unless is_latest?
      return false unless errors.empty?

      self.version = nil
      save
    end

    def new_version
      Contract.where(:name => name, :version => nil).first || \
        dup.tap{|contract| contract.version = nil}
    end

    ##############
    # Validation #
    ##############

    def no_signatures
      return if signatures.empty?
      errors.add(:base, 'Contract cannot be modified because users have signed it')
      false
    end

    protected

    def downcase_name
      self.name = name.try(:downcase)
    end
  end
end
