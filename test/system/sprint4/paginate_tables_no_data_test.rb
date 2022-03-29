require "application_system_test_case"

# Acceptance Criteria:
# 1. As a professor, I should not see the paginate specifications form if no data exists.

class PaginateTablesNoDataTest < ApplicationSystemTestCase
  setup do
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', password: 'professor', password_confirmation: 'professor', is_admin: true)
  end

  def test_no_pagination_specifications_for_no_data
    visit root_url
    login 'msmucker@gmail.com', 'professor'

    visit teams_url
    assert_no_select('per_page')

    visit users_url
    assert_select('per_page')

    visit feedbacks_url
    assert_no_select('per_page')
  end
end
