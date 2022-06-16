require 'http'
require 'json'

module ApiCall
  extend ActiveSupport::Concern

  BASE_URL = 'https://bitex-staging.la'
  API_KEY = '991ace895d440d58b70c3bda981d96d9'
  API_SECRET = '1f8a4b2a3feceaba0763f38f5422df66'
  NONCE = '1'
  USER_ID = '1711'
  SIGNATURE = OpenSSL::HMAC.hexdigest('sha256', API_SECRET, "#{NONCE}#{USER_ID}#{API_KEY}")

  def set_account(email)
    uri = "#{BASE_URL}/api/exchange/accounts"
    headers = { 'Content-Type' => 'application/json', 'X-Exchange-Api-Key' => API_KEY,
                'X-Exchange-Nonce' => NONCE, 'X-Exchange-Signature' => SIGNATURE,
                'X-Exchange-User-Id' => USER_ID, 'X-Exchange' => 'true' }

    data = {
      "data": {
        "type": 'accounts',
        "attributes": {
          "account_email": email.to_s
        }
      }
    }

    response = HTTP.headers(headers).timeout(connect: 5, write: 2, read: 10).post(uri, json: data)

    JSON.parse(response.body)['data'] if response.status.success?
  end

  def get_userid_by_email(email)
    uri = "#{BASE_URL}/api/exchange/accounts"
    headers = { 'Content-Type' => 'application/json', 'X-Exchange-Api-Key' => API_KEY,
                'X-Exchange-Nonce' => NONCE, 'X-Exchange-Signature' => SIGNATURE,
                'X-Exchange-User-Id' => USER_ID, 'X-Exchange' => 'true' }
    response = HTTP.headers(headers).timeout(connect: 5, write: 2, read: 10).get(uri)

    data = JSON.parse(response.body)

    data['data'].each do |account|
      return account['id'] if account['attributes']['account_name'].include? email
    end

    nil
  end

  def create_issue(account_id)
    uri = "#{BASE_URL}/api/compliance/issues"
    headers = { 'Content-Type' => 'application/json', 'X-Exchange-Api-Key' => API_KEY,
                'X-Exchange-Nonce' => NONCE, 'X-Exchange-Signature' => SIGNATURE,
                'X-Exchange-User-Id' => USER_ID, 'X-Exchange' => 'true' }
    data = {
      "data": {
        "type": 'issues',
        "attributes": { "reason_code": 'new_client' },
        "relationships": {
          "account": {
            "data": {
              "id": account_id.to_s,
              "type": 'accounts'
            }
          }
        }
      }
    }

    response = HTTP.headers(headers).timeout(connect: 5, write: 2, read: 10).post(uri, json: data)

    JSON.parse(response.body)['data'] if response.status.success?
  end

  def create_natural_docker_seed(issue_id, first_name, last_name, birth_date, nationality)
    uri = "#{BASE_URL}/api/compliance/natural_docket_seeds"
    headers = { 'Content-Type' => 'application/json', 'X-Exchange-Api-Key' => API_KEY,
                'X-Exchange-Nonce' => NONCE, 'X-Exchange-Signature' => SIGNATURE,
                'X-Exchange-User-Id' => USER_ID, 'X-Exchange' => 'true' }
    data = {
      "data": {
        "type": 'natural_docket_seeds',
        "attributes": {
          "first_name": first_name,
          "last_name": last_name,
          "nationality": nationality,
          "birth_date": birth_date.to_s
        },
        "relationships": {
          "issue": {
            "data": {
              "id": issue_id.to_s,
              "type": 'issues'
            }
          }
        }
      }
    }

    response = HTTP.headers(headers).timeout(connect: 5, write: 2, read: 10).post(uri, json: data)

    JSON.parse(response.body)['data'] if response.status.success?
  end

  def create_domicile_seeds(issue_id, country, state, city, street_address, street_number, postal_code)
    uri = "#{BASE_URL}/api/compliance/domicile_seeds"
    headers = { 'Content-Type' => 'application/json', 'X-Exchange-Api-Key' => API_KEY,
                'X-Exchange-Nonce' => NONCE, 'X-Exchange-Signature' => SIGNATURE,
                'X-Exchange-User-Id' => USER_ID, 'X-Exchange' => 'true' }
    data = {
      "data": {
        "type": 'domicile_seeds',
        "attributes": {
          "country": country,
          "state": state,
          "city": city,
          "street_address": street_address,
          "street_number": street_number.to_s,
          "postal_code": postal_code.to_s,
          "floor": '1',
          "apartment": 'a'
        },
        "relationships": {
          "issue": {
            "data": {
              "id": issue_id, "type": 'issues'
            }
          }
        }
      }
    }

    response = HTTP.headers(headers).timeout(connect: 5, write: 2, read: 10).post(uri, json: data)

    JSON.parse(response.body)['data'] if response.status.success?
  rescue StandardError => e
    e
  end

  def identification_seed(issue_id, document, nationality)
    uri = "#{BASE_URL}/api/compliance/identification_seeds"
    headers = { 'Content-Type' => 'application/json', 'X-Exchange-Api-Key' => API_KEY,
                'X-Exchange-Nonce' => NONCE, 'X-Exchange-Signature' => SIGNATURE,
                'X-Exchange-User-Id' => USER_ID, 'X-Exchange' => 'true' }
    data = {
      "data": {
        "type": 'identification_seeds',
        "attributes": {
          "issuer": nationality.downcase,
          "number": document.to_s,
          "identification_kind_code": 'national_id'
        },
        "relationships": {
          "issue": {
            "data": {
              "id": issue_id,
              "type": 'issues'
            }
          }
        }
      }
    }

    response = HTTP.headers(headers).timeout(connect: 5, write: 2, read: 10).post(uri, json: data)

    JSON.parse(response.body)['data'] if response.status.success?
  rescue StandardError => e
    puts e.message
    e
  end

  def create_email_seeds(issue_id, email)
    uri = "#{BASE_URL}/api/compliance/email_seeds"
    headers = { 'Content-Type' => 'application/json', 'X-Exchange-Api-Key' => API_KEY,
                'X-Exchange-Nonce' => NONCE, 'X-Exchange-Signature' => SIGNATURE,
                'X-Exchange-User-Id' => USER_ID, 'X-Exchange' => 'true' }
    data = {
      "data": {
        "type": 'email_seeds',
        "attributes": {
          "address": email,
          "email_kind_code": 'personal'
        },
        "relationships": {
          "issue": {
            "data": {
              "id": issue_id,
              "type": 'issues'
            }
          }
        }
      }
    }

    response = HTTP.headers(headers).timeout(connect: 5, write: 2, read: 10).post(uri, json: data)

    JSON.parse(response.body)['data'] if response.status.success?
  rescue StandardError => e
    puts e.message
    e
  end

  def create_attachments(id, type, file)
    uri = "#{BASE_URL}/api/compliance/attachments"
    headers = { 'Content-Type' => 'application/json', 'X-Exchange-Api-Key' => API_KEY,
                'X-Exchange-Nonce' => NONCE, 'X-Exchange-Signature' => SIGNATURE,
                'X-Exchange-User-Id' => USER_ID, 'X-Exchange' => 'true' }

    puts "#{File.basename(file)} #{File.size(file)} #{file.content_type} #{file} #{file.path}"
    puts encode_file(file.path)
    data = {
      "data": {
        "type": 'attachments',
        "attributes": {
          "document": encode_file(file.path),
          "document_file_name": File.basename(file),
          "document_content_type": file.content_type
        },
        "relationships": {
          "attached_to_seed": {
            "data": {
              "id": id,
              "type": type
            }
          }
        }
      }
    }

    response = HTTP.headers(headers).post(uri, json: data)
    if response.status.success?
      JSON.parse(response.body)['data']
    else
      puts response.body
    end
  rescue StandardError => e
    puts e.message
    e
  end

  def issue_complete(id)
    uri = "#{BASE_URL}/api/compliance/issues/#{id}/complete"
    headers = { 'Content-Type' => 'application/json', 'X-Exchange-Api-Key' => API_KEY,
                'X-Exchange-Nonce' => NONCE, 'X-Exchange-Signature' => SIGNATURE,
                'X-Exchange-User-Id' => USER_ID, 'X-Exchange' => 'true' }

    response = HTTP.headers(headers).timeout(connect: 5, write: 2, read: 10).patch(uri)

    JSON.parse(response.body)['data'] if response.status.success?
  rescue StandardError => e
    puts e.message
    e
  end

  private

  def encode_file(tmp_route)
    File.open(tmp_route, 'rb') do |file|
      Base64.strict_encode64(file.read)
    end
  end
end
