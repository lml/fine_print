module FinePrint
  class Contract < ActiveRecord::Base
    has_many :signatures, dependent: :destroy, inverse_of: :contract

    has_many :same_name, class_name: 'Contract',
             primary_key: :name, foreign_key: :name

    before_validation :downcase_name
    before_update :no_signatures
    before_destroy :no_signatures

    validates :name, presence: true, format: /\A[\w-]+\z/
    validates :title, presence: true
    validates :content, presence: true
    validates :version, uniqueness: { scope: :name, case_sensitive: false },
                        allow_nil: true

    default_scope -> { order(:name, version: :desc) }

    scope :published, -> { where.not(version: nil) }
    scope :latest, -> do
      fpc = arel_table
      sn = Arel::Table.new(:same_names_fine_print_contracts)
      joins(:same_name).group(:id).having(fpc[:version].eq(sn[:version].maximum))
    end

    def is_published?
      !version.nil?
    end

    def is_latest?
      is_published? && self == same_name.published.first
    end

    def publish
      errors.add(:base, I18n.t('fine_print.contract.errors.already_published')) \
        if is_published?
      return false unless errors.empty?

      self.version = (same_name.published.first.try(:version) || 0) + 1

      save.tap do |success|
        instance_exec(self, &FinePrint.config.contract_published_proc) if success
      end
    end

    def unpublish
      errors.add(:base, I18n.t('fine_print.contract.errors.not_latest')) \
        unless is_latest?
      return false unless errors.empty?

      self.version = nil
      save
    end

    def new_version
      Contract.where(name: name, version: nil).first || \
        dup.tap{|contract| contract.version = nil}
    end

    ##############
    # Validation #
    ##############

    def no_signatures
      return if signatures.empty?
      errors.add(:base, I18n.t('fine_print.contract.errors.already_signed'))
      throw :abort
    end

    protected

    def downcase_name
      self.name = name.try(:downcase)
    end
  end
end
