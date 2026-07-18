module ApplicationHelper
  def age_appropriate_class
    return "" unless current_child_profile

    case current_child_profile.age_group
    when :young
      "ui-young"
    when :middle
      "ui-middle"
    when :teen
      "ui-teen"
    else
      ""
    end
  end

  def age_appropriate_welcome_message
    return "" unless current_child_profile

    case current_child_profile.age_group
    when :young
      I18n.t("helpers.application.welcome_young", name: current_child_profile.name)
    when :middle
      I18n.t("helpers.application.welcome_middle", name: current_child_profile.name)
    when :teen
      I18n.t("helpers.application.welcome_teen", name: current_child_profile.name)
    end
  end
end
