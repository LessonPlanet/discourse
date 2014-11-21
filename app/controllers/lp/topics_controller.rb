class Lp::TopicsController < TopicsController
  POSTS_SINCE = 15.minutes.ago

  def index
    topic_ids = Post.
                public_posts.
                where("posts.created_at >= ?", POSTS_SINCE).
                select("topic_id").
                distinct.
                map{|p| p.topic_id}

    render json: MultiJson.dump(topic_ids)
  end

  def update
    topic_params = {
        title:          params[:topic_title],
        skip_callbacks: true
    }

    topic = Topic.find params[:id]

    Topic.transaction do
      topic.attributes topic_params
      topic.save validate: false
      if params[:category].present?
        category = Category.where(id: params[:category].to_i).first
        topic.changed_to_category(category) if (category && category != topic.category)
      end
    end
    render_json_error(topic) and return if topic.errors.present?

    # update post body
    if params[:topic_body].present?
      post     = topic.posts.where(user_id: topic.user.id).order(:sort_order).first
      post.raw = params[:topic_body]
      post.save validate: false
      render_json_error(post) and return if post.errors.present?
    end

    render_serialized(topic, BasicTopicSerializer)
  end
end
