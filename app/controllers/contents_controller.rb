class ContentsController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
    @user = current_user
    @contents = Content.all
  end

  def new
    Rails.logger.info "DEBUG: new path params: #{params}"
    if params['name'] =='cancel' && params['value'] == 'cancel'
      args = { url: contents_new_url}
      redirect_to root_url(args), method: :get
    end
    @content = Content.new
  end

  def create
    Rails.logger.info ("DEBUG: create path params: #{params}")
    unless params['content'].nil?
      Rails.logger.info "DEBUG: params[content] exists... commit: #{params['commit']}"
      if params['commit'] == ("Save changes")
        Rails.logger.info "DEBUG: params[commit] is Save changes..."
        c = Content.new
        c.name = params[:content][:name]
        c.content = params[:content][:content]
        c.save!
        Rails.logger.info "sending them back to index..."
        redirect_to root_url, method: :get, flash: 'Content created.'
      end
    end
  end

  private

  def safe_params
    params.require(:content).permit(commit: %i[name, content])
  end
end
