class TicketsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :launch

  def index
    # @user = { email: 'pramod.shinde@emeritus.org', name: 'Pramod Shinde'}
    @user = { email: session[:canvas_user_email], name: session[:canvas_user_name] }
    client = Zendesk.new.client
    puts "users ------- #{session[:canvas_user_email]}"
    # @tickets = client.tickets
    if session[:canvas_user_roles]&.include?('Admin')
      @tickets = Zendesk.tickets_by_user(status: params[:status])
    else
      # Dutta 22663352455577 sanjaydutta1@hotmail.com
      # new ticket 836003
      puts "users ------- #{session[:canvas_user_email]}"
      puts user = Zendesk.user_by_email(session[:canvas_user_email])
      if user
        @tickets = Zendesk.tickets_by_user(submitter_id: user['id'], status: params[:status])
      end
    end
  end

  def create
    @user = { email: session[:canvas_user_email], name: session[:canvas_user_name] }
    ticket_hash = params.require(:tickets).permit!.to_h
    ticket_hash.merge!(@user)
    ticket = CreateTicket.new(ticket_hash).process
    flash[:notice] = "Ticket with no <b>#{ticket.id}</b> is created successfully"
    redirect_to tickets_path
  end

  def show
    client = Zendesk.new.client
    @ticket = client.tickets.find(id: params[:id])
    # @ticket = client.tickets.find(id: 799169)
    #ticket = client.tickets.find(id: 799282)
    # ticket = client.tickets.find(id: 799193)
    @comments = @ticket.comments
  end

  def search
    client = Zendesk.new.client
    # @tickets = Zendesk.tickets_by_user(submitter_id: 23853058385049, status: params[:status], ticket_id: params[:ticket_id])
    # @tickets = Zendesk.tickets_by_user(submitter_id: 23853058385049, status: params[:status])
    @tickets = Zendesk.tickets_by_user(status: params[:status], ticket_id: params[:ticket_id])
    render :search
  end

  def launch
    # session[:canvas_user_roles] == 'Learner'
    session[:canvas_user_roles] = params[:roles]
    session[:canvas_user_id] = params[:custom_canvas_user_id]
    session[:canvas_course_id] = params[:custom_canvas_course_id]
    session[:canvas_user_email] = params[:custom_canvas_user_email]
    session[:canvas_user_name] = params[:custom_canvas_user_name]

    redirect_to tickets_path
  end
end
