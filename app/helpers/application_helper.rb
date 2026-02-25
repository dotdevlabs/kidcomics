module ApplicationHelper
  # Generate Lucide icon with data-lucide attribute
  # Usage: <%= icon "book-open", class: "w-6 h-6" %>
  def icon(name, options = {})
    options[:data] ||= {}
    options[:data][:lucide] = name

    # Extract class if provided
    css_class = options.delete(:class)

    # Build HTML attributes
    attrs = options.map { |k, v|
      if k == :data
        v.map { |dk, dv| "data-#{dk.to_s.dasherize}=\"#{dv}\"" }.join(" ")
      else
        "#{k}=\"#{v}\""
      end
    }.join(" ")

    # Add class if provided
    attrs = "class=\"#{css_class}\" #{attrs}" if css_class.present?

    "<i #{attrs}></i>".html_safe
  end

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
