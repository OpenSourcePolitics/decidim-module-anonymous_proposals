# frozen_string_literal: true

require "spec_helper"

describe "Create proposal" do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:component) do
    create(:proposal_component,
           :with_creation_enabled,
           manifest:,
           participatory_space:,
           organization:,
           settings: {
             anonymous_proposals_enabled: true
           })
  end

  let!(:anonymous_group) do
    create(:user_group, organization:, extended_data: { anonymous: true })
  end

  shared_examples "selects the anonymous_group and creates the proposal" do
    it "can select anonymous group as user" do
      expect(page).to have_content("Create proposal as")
      expect(page).to have_content("Anonymous user")
    end

    it "can save the proposal as anonymous" do
      fill_in "Title", with: "Anonymized proposal"
      fill_in "Body", with: "Description of the anonymized proposal"
      select "Anonymous user", from: "Create proposal as"

      expect(Decidim::Proposals::Proposal.from_author(anonymous_group).count).to eq(0)

      click_on "Continue"

      expect(page).to have_content(anonymous_group.name)

      expect(Decidim::Proposals::Proposal.from_author(anonymous_group).count).to eq(1)
    end
  end

  shared_examples "shows anonymous info message and creates proposal" do
    it "shows informative message instead of selector" do
      expect(page).to have_no_content("Create proposal as")
      expect(page).to have_content("Your proposal will be published anonymously")
      expect(page).to have_content(anonymous_group.name)
      expect(page).to have_link("Register")
      expect(page).to have_link("sign in")
    end

    it "can save the proposal as anonymous automatically" do
      fill_in "Title", with: "Anonymized proposal"
      fill_in "Body", with: "Description of the anonymized proposal"

      expect(Decidim::Proposals::Proposal.from_author(anonymous_group).count).to eq(0)

      click_on "Continue"

      expect(Decidim::Proposals::Proposal.from_author(anonymous_group).count).to eq(1)

      proposal = Decidim::Proposals::Proposal.from_author(anonymous_group).last
      expect(proposal.title["en"]).to eq("Anonymized proposal")
    end
  end

  describe "user group is anonymous" do
    it "has anonymous extended data" do
      expect(anonymous_group.extended_data["anonymous"]).to be true
    end
  end

  context "when visiting proposal component with anonymous proposals enabled" do
    it "shows button to create proposal" do
      visit_component

      expect(page).to have_content("New proposal")
      expect(page).to have_content("If you publish your proposal as registered user")
    end
  end

  context "when visiting proposal component without anonymous proposals enabled" do
    before do
      settings = {
        anonymous_proposals_enabled: false
      }
      component.update!(settings:)

      visit_component
    end

    it "does not show announcements" do
      expect(page).to have_no_content("If you publish your proposal as registered user")
    end

    context "when creating a new proposal" do
      context "when the user is not logged_in" do
        before do
          visit_component
          click_on "New proposal"
        end

        it "gets redirected to register/login" do
          expect(page).to have_content("Create an account")
        end
      end

      context "when the user is logged in" do
        before do
          login_as user, scope: :user
          visit_component
          click_on "New proposal"
        end

        it "does not see the anonymous group" do
          expect(page).to have_no_content("Anonymous user")
        end
      end
    end
  end

  context "when creating a new proposal" do
    context "when the user is not logged in" do
      before do
        visit_component
        click_on "New proposal"
      end

      it "shows the announcement" do
        expect(page).to have_content("Do you want other participants to follow you and comment on your proposal?")
      end

      it_behaves_like "shows anonymous info message and creates proposal"
    end

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
        visit_component
        click_on "New proposal"
      end

      it_behaves_like "selects the anonymous_group and creates the proposal"
    end
  end
end
