require "application_system_test_case"

# Acceptance Criteria:
# As a professor, I should be able to use the guidance from the 'Help' page to navigate through the application.

class HelpPageTest < ApplicationSystemTestCase
    setup do
        @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', password: 'professor', password_confirmation: 'professor', is_admin: true)
    end

    def test_filter_instructions
        visit root_url
        login 'msmucker@gmail.com', 'professor'

        visit help_url

        # assert section exists
        assert_text("Feedback & Ratings Filter")

        # assert options for filtering exist
        assert_text("First Name")
        assert_text("Last Name")
        assert_text("Team Name")
        assert_text("Participation Rating")
        assert_text("Effort Rating")
        assert_text("Punctuality Rating")
        assert_text("Priority")
        assert_text("Timestamp")

        # assert specific functionality of options
        ratings = ["participation", "effort", "punctuality"]
        ratings.each do |r|
            assert_text("selected range of #{r} ratings")
        end
    end
end