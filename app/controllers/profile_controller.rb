class ProfileController < ApplicationController
  before_action :set_profile, only: [:show, :edit]
  before_action :set_locale
  has_mobile_fu
  layout :which_layout

  def formats=(values)
    # fall back to the browser view if the mobile or tablet version does not exist
    values << :html if values == [:mobile] or values == [:tablet]

    # DEBUG: force mobile. Uncomment if not debugging!
    #values = [:mobile, :html] if values == [:html]
    # values = [:tablet, :html] if values == [:html]

    super(values)
  end

  def index
  end

  def new
    @values = JSON.dump(I18n.t :popupmessages)
    @profile = Profile.new
  end

  def edit
  end

  def show
  end

  def create
    @profile = Profile.new(profile_params)
    lang = params[:profilelang]

    if lang
      I18n.locale=lang
      puts lang
    end
    respond_to do |format|
      if @profile.save
        format.json { render json: {:ok => true} }
      else
        puts @profile.errors.full_messages.to_sentence
        key = @profile.errors.values[0]
        message = (I18n.translate(key))
        format.json { render json: { ok: false, msg: message}, status: 401 }
      end
    end
  end

  def update
    @profile = Profile.find(params["id"])
    respond_to do |format|
      par = params.require(:profile).permit(:id, :user_id, :firstname, :lastname, :height, :weight, :sex, :dateofbirth, :smoke, :insulin, :default_lang)
      puts par
      if @profile.update(par)
        format.json { render json: { :status => "OK", :msg => "Updated successfully" } }
      else
        format.json { render json: { :status => "NOK", :msg => "Update errror" } }
      end
    end
  end

  def set_default_lang
    p = current_user.profile
    if p
      p.default_lang = I18n.locale
      p.save!
      render :json => {:msg => "Profile update successful"}
      return
    end
    render :json => {:msg => "Profile update error"}
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_profile
      u_id = params[:user_id]
      @profile = Profile.where(user_id: u_id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
      params.require(:profile).permit(:user_id, :firstname, :lastname, :weight, :height, :sex, :smoke, :insulin, :dateofbirth, :default_lang)
    end

    def which_layout
      if is_mobile_device?
        'auth.mobile'
      else
        'auth'
      end
    end

end
