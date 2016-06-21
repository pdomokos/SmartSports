class CustomFormElementsController < ApplicationController
  before_action :check_owner_or_doctor
  include CustomFormElementsCommon
end
