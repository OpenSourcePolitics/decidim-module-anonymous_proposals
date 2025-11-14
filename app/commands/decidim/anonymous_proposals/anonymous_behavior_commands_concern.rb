# frozen_string_literal: true

module Decidim
  module AnonymousProposals
    module AnonymousBehaviorCommandsConcern
      private

      def anonymous?
        @is_anonymous
      end

      def anonymous_group
        Decidim::UserGroup.where(organization:).anonymous.first
      end

      def assign_current_user(user)
        @current_user = anonymous? ? anonymous_group : user
      end

      def user_group
        return if anonymous?

        @selected_user_group
      end

      def allow_anonymous_proposals?
        component.settings.anonymous_proposals_enabled?
      end

      def organization
        @organization ||= component.organization
      end
    end
  end
end
