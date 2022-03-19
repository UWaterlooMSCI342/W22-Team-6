
require "application_system_test_case"


class DownloadCSVTest < ApplicationSystemTestCase
  setup do
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    #students that haven't submitted
    user2 = User.new(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: false)
    user2.save
    user3 = User.new(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Olivera', is_admin: false)
    user3.save
  end
    
  def test_previous_week_missing_feedback_csv
    visit root_url 
    login 'msmucker@gmail.com', 'professor'

    click_on 'Export Previous Missing Feedback'

    assert :success
  end

  def test_previous_week_current_feedback_csv
    visit root_url 
    login 'msmucker@gmail.com', 'professor'

    click_on 'Export Current Missing Feedback'

    assert :success
    # expect( DownloadHelpers::download_content ).to include download_previous
  end
end
