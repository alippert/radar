class UserMailer < ActionMailer::Base
  default :from => 'info@uschybridhigh.org'
  
  def welcome_email(user)
    mail(:to => user.email, :subject => 'Invitation Request Received')
    headers['X-MC-GoogleAnalytics'] = 'uschybridhigh.org'
    headers['X-MC-Tags'] = 'welcome'
  end
end