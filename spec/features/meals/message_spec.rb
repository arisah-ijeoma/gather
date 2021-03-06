require "rails_helper"

feature "meal messages" do
  let!(:meal) { create(:meal, asst_cooks: [create(:user)]) }
  let!(:user) { meal.head_cook }
  let!(:signup) { create(:signup, :with_nums, meal: meal) }

  around do |example|
    with_user_home_subdomain(user) { example.run }
  end

  before do
    login_as(meal.head_cook, scope: :user)
  end

  shared_examples_for "sends message" do |recipient_type, email_count|
    scenario do
      expect do
        visit meal_path(meal)
        click_link "Message"
        select recipient_type, from: "Recipients"
        fill_in "Message", with: "Foo bar"
        click_button "Send Message"
        expect(page).to have_content("Message sent successfully")
        Delayed::Worker.new.work_off
      end.to change { ActionMailer::Base.deliveries.size }.by(email_count)
    end
  end

  it_behaves_like "sends message", "Diners", 1
  it_behaves_like "sends message", "Team", 2
  it_behaves_like "sends message", "Diners + Team", 3
end
