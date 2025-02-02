class MessagesController < ApplicationController
  
  def new
  end

  def create
    recipients = User.where(id: params["recipients"])
    conversation = @current_user.send_message(recipients, params[:message][:body], params[:message][:subject]).conversation
    flash.notice = "Your message has been sent!"
    redirect_to conversation_path(conversation)
  end

end
