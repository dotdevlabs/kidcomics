class OnboardingController < ApplicationController
  skip_before_action :require_login
  before_action :set_onboarding_user, except: [ :start ]
  before_action :redirect_if_completed, except: [ :complete ]

  # POST /onboarding/start - Create user with email only
  def start
    email = params[:email]&.strip&.downcase

    if email.blank?
      redirect_to root_path, alert: t("flash.onboarding.email_blank")
      return
    end

    # Check if user already exists
    user = User.find_by(email: email)

    if user
      if user.onboarding_completed?
        redirect_to login_path, alert: t("flash.onboarding.account_exists")
        return
      else
        # User has a partial registration - trigger magic link flow
        handle_partial_registration(user)
        return
      end
    end

    # Create new user with temporary password
    user = User.new(
      email: email,
      password: SecureRandom.alphanumeric(32),
      name: "User", # Temporary name
      onboarding_completed: false
    )

    if user.save(validate: false)
      session[:onboarding_user_id] = user.id
      session[:user_id] = user.id # Log them in for the session
      redirect_to onboarding_name_path
    else
      redirect_to root_path, alert: t("flash.onboarding.create_failed")
    end
  end

  # GET /onboarding/name - Collect user name
  def name
    @user = @onboarding_user
  end

  # PATCH /onboarding/name - Update user name and create family account
  def update_name
    @user = @onboarding_user
    name = params[:name]&.strip

    if name.blank?
      flash.now[:alert] = t("flash.onboarding.name_blank")
      render :name
      return
    end

    @user.name = name

    if @user.save
      # Create family account automatically
      family_name = "#{name}'s Family"
      FamilyAccount.create!(
        name: family_name,
        owner_id: @user.id
      )

      redirect_to onboarding_child_profile_path
    else
      flash.now[:alert] = t("flash.onboarding.name_errors", errors: @user.errors.full_messages.join(", "))
      render :name
    end
  end

  # GET /onboarding/child - Collect child profile info
  def child_profile
    @child_profile = ChildProfile.new
    @family = @onboarding_user.family_account
  end

  # POST /onboarding/child - Create child profile
  def create_child
    @family = @onboarding_user.family_account

    unless @family
      redirect_to onboarding_name_path, alert: t("flash.onboarding.child_missing")
      return
    end

    @child_profile = @family.child_profiles.build(child_profile_params)

    if @child_profile.save
      # Set this child as the active profile for the session
      session[:child_profile_id] = @child_profile.id

      # Auto-create first book for onboarding (photo-first approach)
      book = @child_profile.books.create!(
        title: "#{@child_profile.name}'s First Book",
        description: "",
        status: "draft",
        is_onboarding_book: true
      )

      # Redirect directly to photo upload (skip the form!)
      redirect_to new_child_profile_book_drawing_path(@child_profile, book),
        notice: t("flash.onboarding.first_drawing")
    else
      flash.now[:alert] = @child_profile.errors.full_messages.join(", ")
      render :child_profile
    end
  end

  # POST /onboarding/complete - Mark onboarding complete and send verification email
  def complete
    if @onboarding_user.onboarding_completed?
      redirect_to dashboard_path
      return
    end

    # Check if user has created at least one book
    family = @onboarding_user.family_account
    has_books = family && family.child_profiles.joins(:books).exists?

    unless has_books
      redirect_to dashboard_path, alert: t("flash.onboarding.complete_first")
      return
    end

    @onboarding_user.update!(onboarding_completed: true)

    # Send verification email if Postmark is configured
    if Setting.postmark_configured?
      begin
        @onboarding_user.send_verification_email
        flash[:notice] = t("flash.onboarding.check_email")
      rescue => e
        Rails.logger.error "Failed to send verification email: #{e.message}"
        flash[:notice] = t("flash.onboarding.complete_check_email")
      end
    else
      flash[:notice] = t("flash.onboarding.complete_welcome")
    end

    session.delete(:onboarding_user_id)
    redirect_to dashboard_path
  end

  private

  def set_onboarding_user
    @onboarding_user = User.find_by(id: session[:onboarding_user_id])

    unless @onboarding_user
      redirect_to root_path, alert: t("flash.onboarding.start_first")
    end
  end

  def redirect_if_completed
    if @onboarding_user&.onboarding_completed?
      redirect_to dashboard_path
    end
  end

  def handle_partial_registration(user)
    if Rails.env.development?
      # In development, auto-authenticate and resume onboarding
      session[:user_id] = user.id
      session[:onboarding_user_id] = user.id
      flash[:notice] = t("flash.onboarding.dev_magic_link")
      redirect_to onboarding_resume_step(user)
    else
      # In production, send magic link email
      send_magic_link_for_partial_registration(user)
      redirect_to root_path, notice: t("flash.onboarding.magic_link_sent", email: user.email)
    end
  end

  def send_magic_link_for_partial_registration(user)
    authentication = NoPassword::Email::Authentication.new(session)
    authentication.email = user.email
    if authentication.valid? && authentication.challenge.save
      authentication.save
      UserMailer.magic_link_email(user, email_authentication_url(authentication.challenge.token)).deliver_later
    end
  rescue => e
    Rails.logger.error "Failed to send magic link for partial registration: #{e.message}"
  end

  def onboarding_resume_step(user)
    if user.family_account.blank?
      onboarding_name_path
    elsif user.family_account.child_profiles.empty?
      onboarding_child_profile_path
    else
      dashboard_path
    end
  end

  def child_profile_params
    params.require(:child_profile).permit(:name, :age)
  end
end
