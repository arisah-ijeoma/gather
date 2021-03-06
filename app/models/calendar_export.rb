# Generates ICS files for various calendars in the system.
require 'icalendar'
class CalendarExport
  class CalendarTypeError < StandardError; end

  MAX_EVENT_AGE = 1.year
  CALENDAR_TYPES = %w(meals community_meals all_meals shifts reservations your_reservations)
  UID_SIGNATURE = "91a772a5ae4a"

  attr_accessor :type, :user

  def initialize(type, user)
    self.type = type
    raise CalendarTypeError unless CALENDAR_TYPES.include?(type)
    self.user = user
  end

  def name
    I18n.t("calendars.#{type}", community: Community.multiple? ? user.community_name : "").strip
  end

  def generate
    cal = Icalendar::Calendar.new
    cal.timezone { |t| t.tzid = Time.zone.tzinfo.name }

    if objects.present?
      class_name = objects.first.class.name.underscore

      objects.each do |obj|
        obj = obj.decorate
        cal.event do |e|
          e.uid = "#{UID_SIGNATURE}_#{class_name}_#{obj.id}"
          e.dtstart = obj.starts_at
          e.dtend = obj.ends_at
          e.location = obj.location_name
          e.summary = summary(obj)
          e.description = description(obj)
          e.url = url(obj)
        end
      end
    end

    cal.append_custom_property("X-WR-CALNAME", name)
    cal.publish
    cal.to_ical
  end

  private

  def objects
    @objects ||= case type
    when "meals"
      base_meals_scope.attended_by(user.household).to_a
    when "community_meals"
      base_meals_scope.hosted_by(user.community).to_a
    when "all_meals"
      base_meals_scope.to_a
    when "shifts"
      user.assignments.includes(:meal).to_a
    when "reservations"
      base_reservations_scope.where(resources: {community_id: user.community_id}).to_a
    when "your_reservations"
      base_reservations_scope.where(reserver_id: user.id).to_a
    else
      raise "Invalid calendar type #{type}"
    end
  end

  def base_meals_scope
    # Eager loading resources due to location.
    MealPolicy::Scope.new(user, Meal).resolve.
      includes(:resources).
      with_max_age(MAX_EVENT_AGE).
      oldest_first
  end

  def base_reservations_scope
    Reservations::ReservationPolicy::Scope.new(user, Reservations::Reservation).resolve.
      includes(:resource, :reserver).
      with_max_age(MAX_EVENT_AGE)
  end

  def summary(obj)
    case class_name(obj)
    when "Meal" then obj.title_or_no_title
    when "Assignment" then obj.title
    when "Reservations::Reservation" then obj.name << (obj.meal? ? "" : " (#{obj.reserver_name})")
    else unknown_class(obj)
    end
  end

  def description(obj)
    case class_name(obj)
    when "Meal" then obj.head_cook.present? ? "By #{obj.head_cook_name}" : nil
    when "Assignment" then nil
    when "Reservations::Reservation" then nil
    else unknown_class(obj)
    end
  end

  def url(obj)
    case class_name(obj)
    when "Meal" then url_for(obj, :meal_url)
    when "Assignment" then url_for(obj.meal, :meal_url)
    when "Reservations::Reservation" then url_for(obj, :reservation_url)
    else unknown_class(obj)
    end
  end

  def unknown_class(obj)
    raise "Unrecognized object class #{class_name(obj)}"
  end

  def class_name(obj)
    # Assumes obj is a decorator.
    obj.object.class.name
  end

  def url_for(obj, url_helper_method)
    host = "#{user.subdomain}.#{Settings.url.host}"
    Rails.application.routes.url_helpers.send(url_helper_method, obj,
      Settings.url.to_h.slice(:port, :protocol).merge(host: host))
  end
end
