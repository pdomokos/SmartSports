class LoginTest < ActionDispatch::IntegrationTest
  setup do
    Capybara.current_driver = Capybara.javascript_driver # :selenium by default
  end

  test 'show login page if not logged in' do
    visit '/'
    page.must_have_content('Sign in to SmartDiab')
  end

  test 'successful login should take to dashboard page' do
    visit '/'
    fill_in 'email', :with => 'balint@abc.de'
    fill_in 'password', :with => 'testpw'
    click_button 'Login'
    page.must_have_content('SmartDiab - intelligent diabetes management')
  end

  test 'failed login should show error popup' do
    visit '/'
    fill_in 'email', :with => 'balint@abc.de'
    fill_in 'password', :with => 'wrongpw'
    click_button 'Login'
    assert find("div#errorPopup['class']").indexOf('hidden')===-1
  end

end

