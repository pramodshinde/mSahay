class TicketsController < ApplicationController
  def index
    client = Zendesk.new.client
    # @tickets = client.tickets
    @tickets = Zendesk.tickets_by_user(submitter_id: 23853058385049, status: params[:status])

    # 23853058385049
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
    @tickets = Zendesk.tickets_by_user(submitter_id: 23853058385049, status: params[:status], ticket_id: params[:ticket_id])
    render :search
  end
end
