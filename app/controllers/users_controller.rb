class UsersController < ApplicationController
  # render new.rhtml
  def new
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_user = @user # !! now logged in
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      flash[:error]  = "Oops! Try again"
      render :action => 'new'
    end
  end

  #Gigya signup
  def social_signup 
    #Valid gigya signature to avoid fraud
    if !is_valid_gigya_signature 
      respond_to do |format|
        flash[ :notice ] =  "Invalid_gigya_signature"
        format.html { redirect_to signup_url and return }
      end
    end

    user_registered_through_gigya = User.authenticate_by_uid(params[:UID], params[:provider])
    #Check the user already registered
    if !user_registered_through_gigya.blank? 
      self.current_user = user_registered_through_gigya
      respond_to do |format|
        flash[:notice] = "Hi #{user_registered_through_gigya.login}. You have logged in successfully."
        format.html {redirect_to session[:return_to] || user_path(user_registered_through_gigya) }
      end
    else
      # Register this new user!
      store_gigya_user_info
      respond_to do |format|
        format.html { redirect_to social_connect_url }
      end
    end
  end

  def social_account_add
    user = User.find(params[:user_id])
    self.current_user = User.authenticate( user.login, params[:user][:password].strip )
     
    if logged_in?
      social_account = SocialAccount.new
      usocial_account = SocialAccount.new
      social_account.user = current_user
      social_account.provider = session[:gigya_user_info][:loginProvider]
      social_account.uid  = session[:gigya_user_info][:UID]
      social_account.save!
      flash[ :notice ] = "Hello #{current_user.login}"
      session[:social_registration] = "yes"
      redirect_to session[:return_to] || user_path(current_user )
    else
      flash[:notice] = "Wrong credentials"
      redirect_to social_account_linking_url(@user.id)
    end
  end

  def social_account_linking
    @user = User.find_by_id(params[:user_id])
  end

  #empty method to transit from gigya call back url
  def social_connect
    @user = get_gigya_user_info if !session[:gigya_user_info].blank?
  end

  #register user with gigya user information
  def social_register
    cookies.delete :auth_token

    # If a user with this email already exists, try to link accounts
    user = User.find_by_email(params[:user][:email])
    if user
      return redirect_to social_account_linking_url(user.id)
    end

    @user = get_gigya_user_info 
    @user.login = params[:user][:login]
    @user.email = params[:user][:email]
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    @user.save!
    social_account = SocialAccount.new
    social_account.user = @user
    social_account.provider = session[:gigya_user_info][:loginProvider]
    social_account.uid  = session[:gigya_user_info][:UID]
    social_account.save!
    session[:gigya_user_info] = nil
    self.current_user = User.authenticate_by_uid(social_account.uid, social_account.provider)
    flash[ :notice ] = "Hello #{current_user.login}"
    session[:social_registration] = "yes"
    redirect_to root_url
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.html { render :action =>  'social_connect' }
    end
  end
end
