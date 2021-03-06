module ProtipsHelper

  def protips_view_breadcrumbs
    @breadcrumbs ||= begin
      breadcrumbs = [["Protips", trending_path]]
      breadcrumbs << ["Fresh", fresh_path]            if params[:order_by] == :created_at
      breadcrumbs << ["Most viewed", popular_path]  if params[:order_by] == :views_count
      breadcrumbs << ["Page #{params[:page]}", nil] if params[:page].to_i > 1
      breadcrumbs = [] if breadcrumbs.size <= 1
      breadcrumbs
    end
  end

  def hide_on_protip_exploration
    return 'hide' if protips_view_breadcrumbs.present?
  end

  def protip_summary
    tags = @protip.tags
    tags << 'programming' if tags.empty?
    "A protip by #{@protip.user.username} about #{tags.to_sentence}."
  end

end
