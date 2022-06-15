require 'json'
class HomeController < ApplicationController
  include ApiCall

  @@issue = nil

  def index
    @email = ''
  end

  def create
    @email = create_params[:email]

    if session[:account].present?
      @account = JSON.parse(session[:account])
    else
      @account = get_userid_by_email(@email)

      @account = set_account(@email)['id'] if @account.nil?
      session[:account] = @account.to_json
    end

    puts 'Account created'

    if session[:issue].present?
      @@issue = JSON.parse(session[:issue])
    else
      @@issue = create_issue(@account)
      session[:issue] = @@issue.to_json
    end

    puts @@issue.to_json
    puts 'Issue created'

    @email_seed = create_email_seeds(@@issue['id'], @email)

    puts 'Email seeds created'

    render :base_information
  end

  def create_base_information
    @natural_docket_seed = create_natural_docker_seed(@@issue['id'], create_params[:first_name], create_params[:last_name],
                                                      create_params[:birth_date], create_params[:nationality])

    puts @natural_docket_seed.to_json
    puts 'Natural Docket Seed created'

    render :domicile
  end

  def create_domicile
    @domicile_seed = create_domicile_seeds(@@issue['id'], create_params[:country], create_params[:state], create_params[:city],
                                           create_params[:street_address], create_params[:street_number], create_params[:postal_code])

    puts @domicile_seed.to_json
    puts 'Domicile Seed created'

    @address_img = create_attachments(@domicile_seed['id'], 'domicile_seeds', create_params[:address_img])

    return render :domicile if @address_img.nil?

    puts @address_img.to_json
    puts 'Address img created'

    render :document
  end

  def create_document
    @@issue = JSON.parse(session[:issue]) if session[:issue].present?

    @document = identification_seed(@@issue['id'], create_params[:document], 'ar')

    puts 'Document seed created'
    puts @document.to_json

    @document_img = create_attachments(@document['id'], 'identification_seeds', create_params[:document_img])

    puts 'Document img created'
    puts @document_img.to_json
    if @document_img.nil?
      @error = @document_img
      return render :document
    end

    render :result
  end

  def complete_issue
    @issue_complete = issue_complete(@@issue['id'])

    puts 'Issue Complete'
    puts @issue_complete.to_json

    reset_session unless @issue_complete.present?

    render :result
  end

  private

  def create_params
    params.permit(:authenticity_token, :commit, :controller, :action,
                  :first_name, :last_name, :birth_date, :nationality, :document,
                  :document_img, :email, :message, :address_img,
                  :country, :state, :city, :street_address, :street_number, :postal_code,
                  address: %i[country state city street_address street_number postal_code floor apartment])
  end
end
