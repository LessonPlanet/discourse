class SiteSerializer < ApplicationSerializer

  attributes :default_archetype,
             :notification_types,
             :post_types,
             :groups,
             :filters,
             :periods,
             :top_menu_items,
             :anonymous_top_menu_items,
             :uncategorized_category_id, # this is hidden so putting it here
             :is_readonly,
             :lessonplanet_root_url

  has_many :categories, serializer: BasicCategorySerializer, embed: :objects
  has_many :post_action_types, embed: :objects
  has_many :topic_flag_types, serializer: TopicFlagTypeSerializer, embed: :objects
  has_many :trust_levels, embed: :objects
  has_many :archetypes, embed: :objects, serializer: ArchetypeSerializer
  has_many :user_fields, embed: :objects, serialzer: UserFieldSerializer


  def default_archetype
    Archetype.default
  end

  def post_types
    Post.types
  end

  def filters
    Discourse.filters.map(&:to_s)
  end

  def periods
    TopTopic.periods.map(&:to_s)
  end

  def top_menu_items
    Discourse.top_menu_items.map(&:to_s)
  end

  def anonymous_top_menu_items
    Discourse.anonymous_top_menu_items.map(&:to_s)
  end

  def uncategorized_category_id
    SiteSetting.uncategorized_category_id
  end

  def is_readonly
    Discourse.readonly_mode?
  end

  def lessonplanet_root_url
    ENV['LESSON_PLANET_ROOT_URL']
  end
end
