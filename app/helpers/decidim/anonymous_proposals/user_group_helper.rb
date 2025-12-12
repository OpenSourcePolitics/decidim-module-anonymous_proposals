# frozen_string_literal: true

module Decidim
  module AnonymousProposals
    # Custom helpers, scoped to the anonymous_proposals engine.
    #
    module UserGroupHelper
      # Renders a user_group select field in a form including the anonymous
      # option if enabled, or an informative message for non-logged users
      # form - FormBuilder object
      # name - attribute user_group_id
      # options - A hash used to modify the behavior of the select field.
      #
      # Returns nothing.
      def user_group_with_anonymous_select_field(form, name, options = {})
        if allow_anonymous_proposals?
          render_anonymous_field(form, name, options)
        elsif user_signed_in?
          render_standard_select(form, name, options)
        end
      end

      private

      def render_anonymous_field(form, name, options)
        if user_signed_in?
          render_select_with_anonymous(form, name, options)
        else
          render_anonymous_info_message(form, name)
        end
      end

      def render_select_with_anonymous(form, name, options)
        user_groups = Decidim::UserGroups::ManageableUserGroups.for(current_user).verified
        choices = build_choices(user_groups)
        selected = determine_selected_group(form, options)

        form.select(
          name,
          choices,
          selected:,
          include_blank: current_user.name,
          label: options.fetch(:label, true)
        )
      end

      def render_anonymous_info_message(form, name)
        info_message = content_tag(:div, class: "callout secondary") do
          content_tag(:p, class: "mb-2") do
            concat content_tag(:strong, "📝 #{t("anonymous_author_notice", scope: "decidim.anonymous_proposals")}")
            concat " "
            concat t("anonymous_author_explanation", scope: "decidim.anonymous_proposals", anonymous_label: anonymous_group.name || anonymous_group_label)
          end +
            content_tag(:p, class: "mb-0 text-sm") do
              t(
                "register_to_publish_with_name_html",
                scope: "decidim.anonymous_proposals",
                register_link: link_to(t("register", scope: "decidim.anonymous_proposals"), decidim.new_user_registration_path),
                login_link: link_to(t("new_session", scope: "decidim.anonymous_proposals"), decidim.new_user_session_path)
              ).html_safe
            end
        end

        hidden_field = form.hidden_field(name, value: anonymous_group&.id)

        info_message + hidden_field
      end

      def render_standard_select(form, name, options)
        user_groups = Decidim::UserGroups::ManageableUserGroups.for(current_user).verified

        user_group_select_field(form, name, options) if current_organization.user_groups_enabled? && user_groups.any?
      end

      def build_choices(user_groups)
        groups = user_groups.map { |g| [g.name, g.id] }
        groups + anonymous_group_choice
      end

      def anonymous_group_choice
        return [] if anonymous_group.blank?

        [[anonymous_group_label, anonymous_group.id]]
      end

      def anonymous_group_label
        t("anonymous_user", scope: "decidim.proposals.proposals.new")
      end

      def determine_selected_group(form, options)
        (form.object.user_group_id || (options[:select_anonymous] && anonymous_group&.id)).presence
      end
    end
  end
end
