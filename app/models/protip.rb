class Protip < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_format, :use => :slugged
  paginates_per 30

  BIG_BANG = Time.parse("05/07/2012").to_i #date protips were launched
  before_update :cache_cacluated_score!
  before_create :generate_public_id

  belongs_to :user, autosave: true
  has_many :comments, dependent: :destroy
  has_many :likes, as: :likable, dependent: :destroy

  validates :title, presence: true, length: { minimum: 5, maximum:  255 }
  validates :body, presence: true
  validates :tags, presence: true
  validates :slug, presence: true

  scope :random, ->(count=1) { order("RANDOM()").limit(count) }
  scope :recently_created, ->(count=5) { order(created_at: :desc).limit(count)}
  scope :recently_most_viewed, ->{ order(views_count: :desc).where(public_id: %w{ewk0mq kvzbpa vsdrug os6woq w7npmq _kakfa}) }

  def to_param
    self.public_id
  end

  def display_date
    created_at.to_formatted_s(:explicitly_bold)
  end

  def hearts_count
    likes_count
  end

  def slug_format
    title.to_s
  end

  def images
    image_matching_regex = /(https?:\/\/[\w.-\/]*?\.(jpe?g|gif|png))/
    body.to_s.scan(image_matching_regex)
  end

  def cacluate_content_quality_score
    decent_article_size = 300
    max_boost = 3.0
    factor = 1
    factor += [(body.length/decent_article_size), max_boost].min
    factor += [images.size, max_boost].min
    factor * (weight = 20)
  end

  def cacluate_score
    return 0 if flagged?
    half_life      = 4.days.to_i
    # gravity        = 1.8 #used to look at upvote_velocity(1.week.ago)
    views_score    = views_count / 100.0
    votes_score    = likes_count
    comments_score = comments.size #used to consider comment likes as upvotes (.reduce(:+))
    quality_score  = cacluate_content_quality_score
    author_score   = [-14 + user.account_age_in_days, 1].min

    points = [votes_score + views_score + comments_score + quality_score + author_score, 0].max
    total  = (created_at || Time.now).to_i.to_f / half_life + Math.log2(points + 1)

    Rails.logger.info "#{public_id} => #{score} (v:#{views_score} u:#{votes_score} q:#{quality_score} a:#{author_score})"

    total
  end

  def generate_public_id
    self.public_id = SecureRandom.urlsafe_base64(4).downcase
    #retry if not unique
    generate_public_id unless Protip.where(public_id: self.public_id).blank?
  end

  def cache_cacluated_score!
    self.score = cacluate_score
  end

  def editable_tags
    tags.join(', ')
  end

  def editable_tags=(val)
    self.tags = val.split(',').collect(&:strip)
  end

end
