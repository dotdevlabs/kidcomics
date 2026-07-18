class UserLocalesController < ApplicationController
  def create
    locale = params[:locale].to_sym
    if I18n.available_locales.include?(locale)
      current_user.update_column(:locale, locale.to_s)
    end
    redirect_back(fallback_location: root_path)
  end
end
