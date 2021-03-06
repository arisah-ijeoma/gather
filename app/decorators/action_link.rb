class ActionLink < ApplicationDecorator
  attr_accessor :object, :action, :icon, :method, :path, :confirm

  def initialize(object, action, icon:, path:, method: :get, confirm: false)
    self.object = object
    self.action = action
    self.icon = icon
    self.path = path
    self.method = method
    self.confirm = confirm
  end

  def render
    return @rendered if defined?(@rendered)
    @rendered = if h.policy(object).send("#{action}?")
      params = {title: name, method: method, class: "btn btn-default"}
      params[:data] = {confirm: confirm_msg} if confirm_msg
      h.link_to(icon_tag << name_tag, path, params)
    else
      nil
    end
  end

  private

  def icon_tag
    h.icon_tag(icon)
  end

  def name_tag
    h.content_tag(:span, name, class: "action-name")
  end

  def name
    t(:"action_names.#{i18n_key}.#{action}", default: :"action_names.common.#{action}")
  end

  def i18n_key
    object.model_name.i18n_key
  end

  def confirm_msg
    return @confirm_msg if defined?(@confirm_msg)
    @confirm_msg = confirm ? I18n.t("confirmations.#{object.model_name.i18n_key}.#{action}", confirm) : nil
  end
end
