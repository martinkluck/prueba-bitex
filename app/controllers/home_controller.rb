require 'json'
class HomeController < ApplicationController
  include ApiCall

  after_action :create_issue, only: [:create]

  def index
    @email = ''
  end

  def create
    @email = create_params[:email]
    session[:email] = @email
    if session[:account].present?
      @account = session[:account]
    else
      @account = get_userid_by_email(@email)
      @account = set_account(@email)['id'] if @account.nil?
      session[:account] = @account
    end
    redirect_to base_information_path and return
  rescue StandardError => e
    reset_session
    redirect_to root_path, error: e.message and return
  end

  def base_information; end

  def create_base_information
    @email_seed = create_email_seeds(session[:issue], session[:email])
    @natural_docket_seed = create_natural_docker_seed(session[:issue], create_params[:first_name], create_params[:last_name],
                                                      create_params[:birth_date], create_params[:nationality])
    redirect_to domicile_path and return
  rescue StandardError => e
    reset_session
    redirect_to root_path, error: e.message and return
  end

  def domicile; end

  def create_domicile
    @domicile_seed = create_domicile_seeds(session[:issue], create_params[:country], create_params[:state], create_params[:city],
                                           create_params[:street_address], create_params[:street_number], create_params[:postal_code])
    @address_img = create_attachments(@domicile_seed['id'], 'domicile_seeds', create_params[:address_img])
    raise StandardError, 'Address image error' if @address_img.nil?

    redirect_to document_path and return
  rescue StandardError => e
    redirect_to domicile_path, e.message and return
  end

  def document; end

  def create_document
    @document = identification_seed(session[:issue], create_params[:document], 'ar')
    @document_img = create_attachments(@document['id'], 'identification_seeds', create_params[:document_img])
    raise StandardError, @document_img if @document_img.nil?

    redirect_to result_path and return
  rescue StandardError => e
    redirect_to document_path, error: e.message and return
  end

  def result; end

  def complete_issue
    @issue_complete = issue_complete(session[:issue])
    reset_session unless @issue_complete.present?
    redirect_to result_path and return
  rescue StandardError => e
    redirect_to result_path, error: e.message and return
  end

  private

  def create_params
    params.permit(:authenticity_token, :commit, :controller, :action,
                  :first_name, :last_name, :birth_date, :nationality, :document,
                  :document_img, :email, :message, :address_img,
                  :country, :state, :city, :street_address, :street_number, :postal_code,
                  address: %i[country state city street_address street_number postal_code floor apartment])
  end

  def create_issue
    session[:issue] = create_issue(session[:account])['id'] unless session[:issue].present?
  rescue StandardError => e
    reset_session
    flash.now[:error] = e.message
    e.message
  end
end
