module Deactivatable
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where(deactivated_at: nil) }
    scope :active_or_selected, ->(selected) {
      where("deactivated_at IS NULL OR id = #{selected.try(:id) || -1}") }
    scope :deactivated_last, -> { order("COALESCE(deactivated_at, '0001-01-01 00:00:00')") }
  end

  def activate
    update_attribute(:deactivated_at, nil)
  end

  def deactivate(options = {})
    update_attribute(:deactivated_at, Time.current)
    after_deactivate if respond_to?(:after_deactivate) && !options[:skip_callback]
  end

  def active?
    deactivated_at.nil?
  end

  def inactive?
    !active?
  end
end
