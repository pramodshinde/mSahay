require "net/http"
class CreateTicket

  ZENDESK_API_CUSTOM_FIELDS = {
    "query_type"=>"360028727092",
    "canvas_course_id"=>"360000461651",
    "course_name"=>"360002367791",
    "course_start_date"=>"360031730772",
    "course_end_date"=>"360031800231",
    "assignment_extension_eligible"=>"360032712831"
  }.with_indifferent_access

  def initialize(params)
    @params = params.with_indifferent_access
    @params[:canvas_course_id] = 61
    @params[:custom_fields] = [
      { id: 360028727092, value: @params[:query_type] },
      { id: 360000461651, value: @params[:canvas_course_id] }
    ]
    puts "create ticket-- #{@params.inspect}"
    set_client
  end

  def process
    ticket = ZendeskAPI::Ticket.new(
      @client,
      subject: "#{Rails.env.production? ? '' : '[EmHack TEST] '}#{@params[:subject]}",
      comment: { value: @params[:description] },
      custom_fields: @params[:custom_fields],
      requester: { name: 'Student', email: @params[:email]},
      tags: [@params[:canvas_course_id]]
    )
    add_attachments(ticket, @params[:attachments]) if @params[:attachments]
    ticket.tap(&:save!)
  end

  def add_attachments(ticket, attachments)
    ticket.comment.uploads = attachments.collect(&:path)
  end

  def self.custom_fields_map
    @custom_fields_map ||= ENV.fetch('ZENDESK_API_CUSTOM_FIELDS').split(',').to_h { |value|
      value.split(':')
    }.with_indifferent_access
  end


  def set_client
    @client ||= ZendeskAPI::Client.new do |config|
      config.url = ENV.fetch('ZENDESK_API_URL')
      config.username = ENV.fetch('ZENDESK_API_USERNAME')
      config.token = ENV.fetch('ZENDESK_API_TOKEN')

      config.retry = true
      config.raise_error_when_rate_limited = false
      config.logger = Rails.logger
    end
  end
end