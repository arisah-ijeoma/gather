module MealsHelper
  def meal_link(meal)
    link_to(meal.title_or_no_title, meal_url(meal))
  end

  def meal_url(meal)
    url_in_community(meal.community, meal_path(meal))
  end

  def meal_date_time(meal, with_break: false)
    date_fmt = params[:time] == "all" ? :short_date_with_yr : :short_date
    spacer = with_break ? tag(:br) : " "
    content_tag(:span, meal.served_at.to_formatted_s(date_fmt), class: "date") <<
      spacer << content_tag(:span, meal.served_at.to_formatted_s(:regular_time), class: "time")
  end

  def meal_action_icons(meal, options = {})
    options[:except] = Array.wrap(options[:except] || [])
    to_show = %i(edit summary reopen close finalize cancel send_message) - options[:except]
    links = []
    title = meal.title || "Untitled"
    to_show.each do |action|
      next unless policy(meal).send("#{action}?")
      name = options[:show_name] ? " " << t("action_names.#{action}") : ""
      title = t("action_names.#{action}")

      case action
      when :edit
        links << link_to(icon_tag("pencil") << name, edit_meal_path(meal), title: title)
      when :summary
        links << link_to(icon_tag("file-text") << name, summary_meal_path(meal), title: title)
      when :close
        links << link_to(icon_tag("lock") << name, close_meal_path(meal), title: title, method: :put)
      when :finalize
        links << link_to(icon_tag("certificate") << name, new_meal_finalize_path(meal), title: title)
      when :cancel
        links << link_to(icon_tag("ban") << name,
          new_meal_message_path(meal, cancel: 1), title: title)
      when :reopen
        links << link_to(icon_tag("unlock") << name, reopen_meal_path(meal), title: title, method: :put)
      when :send_message
        links << link_to(icon_tag("envelope") << name, new_meal_message_path(meal), title: title)
      end
    end

    cls = options[:show_name] ? "action-icons-with-names" : ""
    content_tag(:div, links.reduce(:<<), class: "action-icons #{cls}")
  end

  def signup_info(signup)
    icon_tag("check") << " #{signup.total}"
  end

  def signup_link(meal)
    link_to(current_user.credit_exceeded?(meal.community) ? icon_tag("ban") : "Sign Up", meal_url(meal))
  end

  def signup_count(meal)
    icon = meal.full? ? "exclamation-circle" : "users"
    "#{icon_tag(icon)} #{meal.signup_count}/#{meal.capacity}".html_safe
  end

  def signup_label(type)
    icon_tag("question-circle", title: t("signups.tooltips.#{type}"), data: {toggle: "tooltip"}) <<
      t("signups.diner_types.#{type}", count: 1)
  end

  def community_invited?(meal, community)
    meal.community_ids.include?(community.id)
  end

  # We should disable the "own" community checkbox for most users.
  def disable_community_checkbox?(meal, community)
    disable = meal.community == community && community_invited?(meal, community)
    disable ? "disabled" : nil
  end

  def sorted_allergens
    prefix = "activerecord.attributes.meal.allergen_"
    Meal::ALLERGENS.sort_by { |a| [a == "none" ? 1 : 0, I18n.t("#{prefix}_#{a}")] }
  end
end
