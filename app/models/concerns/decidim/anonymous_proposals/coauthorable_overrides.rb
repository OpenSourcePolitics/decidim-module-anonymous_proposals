# frozen_string_literal: true

module Decidim
  module AnonymousProposals
    module CoauthorableOverrides
      extend ActiveSupport::Concern

      included do
        def add_coauthor(author, extra_attributes = {})
          return if author.blank? && persisted?

          author, user_group = process_anonymous_author(author, extra_attributes)

          return if coauthor_already_exists?(author, user_group)

          create_or_build_coauthorship(author, extra_attributes)
          authors << author
        end

        private

        def process_anonymous_author(author, extra_attributes)
          user_group = extra_attributes[:user_group]

          if should_use_anonymous_author?(author, user_group)
            extra_attributes.delete(:user_group)
            return [anonymous_group, nil]
          end

          [author, user_group]
        end

        def should_use_anonymous_author?(author, user_group)
          allow_anonymous_proposals? && (author.blank? || user_group == anonymous_group)
        end

        def coauthor_already_exists?(author, user_group)
          return true if user_group && coauthorships.exists?(user_group:)
          return true if user_group.blank? && coauthorships.exists?(
            decidim_author_id: author.id,
            decidim_author_type: author.class.base_class.name
          )

          false
        end

        def create_or_build_coauthorship(author, extra_attributes)
          coauthorship_attributes = extra_attributes.merge(author:)

          if persisted?
            coauthorships.create!(coauthorship_attributes)
          else
            coauthorships.build(coauthorship_attributes)
          end
        end

        def allow_anonymous_proposals?
          component.settings.anonymous_proposals_enabled?
        end

        def anonymous_group
          Decidim::UserGroup.where(organization:).anonymous.first
        end
      end
    end
  end
end
