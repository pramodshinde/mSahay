require "net/http"
class Zendesk
  attr_reader :client

  def initialize
    @client = ZendeskAPI::Client.new do |config|
      config.url = ENV.fetch('ZENDESK_API_URL')
      config.username = ENV.fetch('ZENDESK_API_USERNAME')
      config.token = ENV.fetch('ZENDESK_API_TOKEN')

      config.retry = true
      config.raise_error_when_rate_limited = false
      config.logger = Rails.logger
    end
  end


  def self.api_key
    key = "#{ENV.fetch('ZENDESK_API_USERNAME')}/token:#{ENV.fetch('ZENDESK_API_TOKEN')}".squish
    Base64.urlsafe_encode64(key)
  end

  # email='contactshelina@hotmail.com'
  def self.user_by_email(email)
    return nil unless email
    uri = URI("#{ENV.fetch('ZENDESK_API_URL')}/users/search.json")
    uri.query = URI.encode_www_form("query": "email:#{email}")
    request = Net::HTTP::Get.new(uri, "Content-Type": "application/json")
    request['Authorization'] = "Basic #{api_key}"
    response = Net::HTTP.start uri.hostname, uri.port, use_ssl: true do |http|
      http.request(request)
    end
    JSON.parse(response.body)['users'][0]
  rescue StandardError => e
    return nil
  end

  def self.tickets_by_user(submitter_id: nil, status: nil, ticket_id: nil)
    # submitter_id=23853058385049, status='closed'
    uri = URI("#{ENV.fetch('ZENDESK_API_URL')}/search.json")
    puts "----------------------------- tickets_by_user"
    query = { submitter_id: submitter_id, status: status, ticket_id: ticket_id }.map{|k, v| "#{k}:#{v}" if v.present? }.join(" ")
    puts query_params = { per_page: 1000, page: 1, query: "type:ticket #{query}".squish }
    # uri.query = URI.encode_www_form("query": "type:ticket status:#{status}", "per_page": 1000, page: 1) if status
    # uri.query = URI.encode_www_form("query": "type:ticket submitter_id:#{submitter_id}", "per_page": 1000, page: 1) if submitter_id
    # uri.query = URI.encode_www_form("query": "type:ticket status:#{status} submitter_id:#{submitter_id}", "per_page": 1000, page: 1) if status && submitter_id
    # uri.query = URI.encode_www_form("query": "type:ticket", "per_page": 1000, page: 1) if status.blank? && submitter_id.blank?
    uri.query = URI.encode_www_form(query_params)
    request = Net::HTTP::Get.new(uri, "Content-Type": "application/json")
    request['Authorization'] = "Basic #{api_key}"
    response = Net::HTTP.start uri.hostname, uri.port, use_ssl: true do |http|
      http.request(request)
    end
    JSON.parse(response.body)['results']
  rescue StandardError => e
    return nil
  end
end
