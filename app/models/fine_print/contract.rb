module FinePrint
  class Contract < ActiveRecord::Base
    has_many :signatures, :inverse_of => :contract

    has_many :same_name, :class_name => 'Contract', :primary_key => :name, :foreign_key => :name

    attr_accessible :content, :title, :name

    before_validation :downcase_name

    validates_presence_of :name, :title, :content
    validates_format_of :name, :with => /\A\w+\z/
    validates_uniqueness_of :version, :scope => :name, :case_sensitive => false

    default_scope order(:name, 'version DESC')

    scope :published, where(arel_table[:version].not_eq(nil))
    scope :latest, published
      .joins(:same_name)
      .group(:id)
      .having(:version => arel_table.alias(:same_names_fine_print_contracts)[:version]
                          .maximum.tap{|mvq| mvq.alias = nil})

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
      self.version = (same_name.published.first.try(:version) || 0) + 1
      save
    end

    def unpublish
      self.version = nil
      save
    end

    def draft_copy
      dup.tap{|contract| contract.version = nil}
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

    protected

    def downcase_name
      self.name = name.downcase
    end
  end
end
