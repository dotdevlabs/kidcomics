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
      "Hi #{current_child_profile.name}! 🌈"
    when :middle
      "Welcome back, #{current_child_profile.name}!"
    when :teen
      "Hey #{current_child_profile.name}"
    end
  end
end
