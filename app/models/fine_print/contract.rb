module FinePrint
  class Contract < ActiveRecord::Base
    has_many :signatures, :inverse_of => :contract

    has_many :same_name, :class_name => 'Contract', :primary_key => :name, :foreign_key => :name

    before_validation :downcase_name
    before_update :no_signatures
    before_destroy :no_signatures

    validates_presence_of :name, :title, :content
    validates_format_of :name, :with => /\A\w+\z/
    validates_uniqueness_of :version, :scope => :name, :case_sensitive => false

    default_scope { order(:name, 'version DESC') }

    scope :published, lambda { where(arel_table[:version].not_eq(nil)) }
    scope :latest, lambda {
      published.joins(:same_name)
               .group('fine_print_contracts.id')
               .having(:version =>
                       arel_table.alias(:same_names_fine_print_contracts)[:version].maximum.tap{|mvq| mvq.alias = nil})
    }

    def is_published?
      !version.nil?
    end

    def is_latest?
      is_published? && version == same_name.maximum(:version)
    end

    def sign(user)
      FinePrint.sign_contract(self, user)
    end

    def signed_by?(user)
      FinePrint.signed_contract?(self, user)
    end

    def publish
      no_signatures
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

    def draft_copy
      Contract.where(:name => name, :version => nil).first || dup.tap{|contract| contract.version = nil}
    end

    ##################
    # Access Control #
    ##################

    def can_be_updated?
      signatures.empty?
    end

    def can_be_published?
      signatures.empty? && !is_published?
    end

    def can_be_unpublished?
      signatures.empty? && is_latest?
    end

    alias_method :can_be_destroyed?, :can_be_updated?

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
      self.name = name.downcase
    end
  end
end
