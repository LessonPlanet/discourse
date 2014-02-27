require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class LessonPlanet < OmniAuth::Strategies::OAuth2
      AUTH_URL = ENV['LESSON_PLANET_AUTH_URL'] || 'https://www.lessonplanet.com'

      option :name, 'lessonplanet'

      option :client_options, {
          site: AUTH_URL,
          token_url: '/oauth/token',
          authorize_url: '/oauth/authorize'
      }

      def raw_info
        response = access_token.get('/api/v2/account.json')
        Rails.logger.info "-------------------- Raw response: #{response.inspect}"
        @raw_info ||= response.parsed
      end
    end

  end
end

OmniAuth.config.add_camelization 'lessonplanet', 'LessonPlanet'
