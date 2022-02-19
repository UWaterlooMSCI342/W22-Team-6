  require 'test_helper'

  class ReportsControllerTest < ActionDispatch::IntegrationTest

  setup do
    Option.create(reports_toggled: true)
    @prof = User.create(email: 'msmucker@gmail.com', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    
    # Create reporter and reportee
    @reporter = User.new(email: 'dwightschrute@dundermifflin.com', password: 'password', password_confirmation: 'password', first_name: 'Dwight', last_name: 'Schrute', is_admin: false)

    @reportee = User.new(email: 'jameshalpert@dundermifflin.com', password: 'password', password_confirmation: 'password', name: 'Jim Halpert', is_admin: false)
    @reporter.save
    @reportee.save

    # Login reporter
    post('/login', params: { email: 'dwightschrute@dundermifflin.com', password: 'password'})

    # Create report
    @report = Report.new(reporter_id: @reporter.id, reportee_id: @reportee.id, description: 'Stapler was placed in jello.')
    @report.save
    
  end    

  def test_reports_disabled 
    Option.destroy_all
    Option.create(reports_toggled: false)
    assert_no_difference('Report.count') do
      post '/reports', params: { report: { reporter_id: @report.reporter_id, reportee_id: @report.reportee_id, description: @report.description } }
    end
    assert_redirected_to root_path
  end

  test "should get index" do
    post('/login', params: { email: 'msmucker@gmail.com', password: 'professor' })
    get reports_url
    assert_response :success
  end

  test "should get new" do 
    get new_report_path 
    assert_response :success
  end

  test "should create report" do 
    assert_difference('Report.count') do 
      post '/reports', params: { report: { reporter_id: @report.reporter_id, reportee_id: @report.reportee_id, description: @report.description } }
    end
  end

end