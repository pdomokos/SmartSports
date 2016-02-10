module AuthHelper
  def check_doctor()
    if self.try(:current_user).try(:doctor?)
      return true
    end
    return false
  end
  alias_method :doctor?, :check_doctor

  def check_admin()
    if self.try(:current_user).try(:admin?)
      return true
    end
    return false
  end
  alias_method :admin?, :check_admin

  def check_owner()
    user_id = params[:user_id].to_i
    if self.try(:current_user).try(:id) == user_id
      return true
    end
    return false
  end
  alias_method :owner?, :check_owner
end