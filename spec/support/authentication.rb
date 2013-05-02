module ControllerHelpers
  def sign_in(user = double('user'))
    if user.nil?
      request.env['warden'].stub(:authenticate!).
        and_throw(:warden, {:scope => :user})
      controller.stub :current_user => nil
    else
      request.env['warden'].stub :authenticate! => user
      controller.stub :current_user => user
    end
  end
end

shared_context 'authenticated' do
  before :each do
    @nickname = 'test'

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
          :provider => 'github',
          :uid => '123545',
          :info => { 'name' => 'test', :email => 'me@example.com', :nickname => @nickname },
          :credentials => { 'token' => '123456' },
          :extra => { 'raw_info' => { 'gravatar_id' => '123456' } }
    })
  end

  def login
    visit root_path
    click_link 'Sign in with Github'
  end

  def logout
    click_link "user_dropdown"
    click_link "Logout"
  end

  def create_project(name, options={})
    @project_key = 'FOO'

    visit new_project_path

    within("#new_project") do
      fill_in 'Key', :with => @project_key
      fill_in 'Name', :with => name
      fill_in 'Description', :with => name
      choose 'Private' if options[:private]
    end

    click_button 'Create Project'
  end

  def create_issue(summary)
    visit new_issue_path(:user => @nickname, :key => @project_key)

    within("#new_issue") do
      fill_in 'issue_summary', :with => summary
    end

    click_button "Create Issue"
  end

  def create_sprint
    visit sprints_path(:user => @nickname, :key => @project_key)
    find(".planning-new").click
  end

  def start_sprint
    click_button "Start"
  end
end
