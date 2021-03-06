class ProtipsController < ApplicationController
  before_action :require_login, only: [:new, :create, :edit, :update]

  def index
    order_by = (params[:order_by] ||= 'score')
    @protips = Protip.includes(:user).order({order_by => :desc}).page params[:page]
  end

  def show
    return (@protip = Protip.random.first) if params[:id] == 'random'
    @protip = Protip.find_by_public_id!(params[:id])

    if params[:slug] != @protip.slug
      seo_url = slug_protips_url(id: @protip.public_id, slug: @protip.slug)
      return redirect_to(seo_url, status: 301)
    end

    update_view_count(@protip)
  end

  def new
    @protip = Protip.new
  end

  def edit
    @protip = Protip.find_by_public_id!(params[:id])
    render action: 'new'
  end

  def update
    @protip = Protip.find_by_public_id!(params[:id])
    return head(:forbidden) unless current_user.can_edit?(@protip)
    @protip.update(protip_params)
    if @protip.save
      redirect_to protip_url(@protip)
    else
      render action: 'new'
    end
  end

  def create
    @protip = Protip.new(protip_params)
    @protip.user = current_user
    if @protip.save
      redirect_to protip_url(@protip)
    else
      render action: 'new'
    end
  end

  def destroy
    @protip = Protip.find_by_public_id!(params[:id])
    return head(:forbidden) unless current_user.can_edit?(@protip)
    @protip.destroy
    redirect_to profile_protips_url(username: @protip.user.username, anchor: 'protips')
  end

  protected
  def protip_params
    params.require(:protip).permit(:editable_tags, :body, :title)
  end

  def update_view_count(protip)
    if !browser.bot? && browser.known?
      recently_viewed = cookies[:viewd_protips].to_s.split(':')
      if !recently_viewed.include?(protip.public_id)
        protip.increment!(:views_count)
        recently_viewed << protip.public_id
      end
      cookies[:viewd_protips] = {
        value:    recently_viewed.join(':'),
        expires:  10.minutes.from_now
      }
    end
  end

end
