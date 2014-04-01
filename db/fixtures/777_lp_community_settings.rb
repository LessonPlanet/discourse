# Configure Discourse Settings with Lesson Planet Community Settings (rake db:seed_fu)
#

# Load the latest settings
SiteSetting.refresh!

#
# SSO
#
SiteSetting.enable_sso                        = true
SiteSetting.sso_url                           = ENV['SSO_URL']
SiteSetting.sso_secret                        = ENV['SSO_SECRET']
SiteSetting.sso_overrides_email               = true
SiteSetting.sso_overrides_username            = true
SiteSetting.sso_overrides_name                = true
SiteSetting.enable_names                      = true

#
# General
#
SiteSetting.enable_local_account_create       = false
SiteSetting.enforce_global_nicknames          = false
SiteSetting.default_external_links_in_new_tab = true


#
# LessonPlanet API
#
user = User.where(username_lower: ENV['API_USERNAME'].downcase).first
if user.blank?
  user = User.seed do |u|
    u.name = "Lesson Planet"
    u.username = ENV['API_USERNAME']
    u.username_lower = ENV['API_USERNAME'].downcase
    u.email = "member_services@lessonplanet.com"
    u.password = SecureRandom.hex
    # TODO localize this, its going to require a series of hacks
    u.bio_raw = "Not a real person. A global user for system notifications and other system tasks."
    u.active = true
    u.admin = true
    u.moderator = true
    u.email_direct = false
    u.approved = true
    u.email_private_messages = false
    u.trust_level = TrustLevel.levels[:elder]
  end.first
end

if user
  api_key = ApiKey.where(user_id: user.id).first_or_initialize
  api_key.update(key: ENV['API_KEY'], created_by: user)
end

# Categories
categories = {
    classroom_support: { name: 'Classroom Support', color: 'BF1E2E', id: 100 },
    college_career_readiness: { name: 'College & Career Readiness', color: 'F1592A', id: 102 },
    common_core_standards: { name: 'Common Core & Standards', color: 'F7941D', id: 103 },
    english_language_arts: { name: 'English Language Arts', color: '9EB83B', id: 104 },
    health: { name: 'Health', color: '3AB54A', id: 105 },
    homeschool: { name: 'Homeschool', color: '12A89D', id: 106 },
    languages: { name: 'Languages', color: '25AAE2', id: 107 },
    lifestyle: { name: 'Lifestyle', color: '0E76BD', id: 108 },
    math: { name: 'Math', color: '652D90', id: 109 },
    physical_education: { name: 'Physical Education', color: '92278F', id: 110 },
    programs: { name: 'Programs', color: 'ED207B', id: 111 },
    science: { name: 'Science', color: '25AAE1', id: 112 },
    social_studies: { name: 'Social Studies', color: 'AB9364', id: 113 },
    technology: { name: 'Technology', color: 'D2691E', id: 114 },
    visual_performing_arts: { name: 'Visual & Performing Arts', color: '800080', id: 115 }
}
categories.values.each do |category|
  category = Category.find_or_initialize_by id: category[:id]
  category.attributes = { name: category[:name], user_id: Discourse.system_user.id, color: category[:color], text_color: 'ffffff' }
  category.save!
end
# Update auto_increment field
Category.exec_sql "SELECT setval('categories_id_seq', (SELECT MAX(id) from categories));"
