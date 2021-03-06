require "rails_helper"

feature "reservation form" do
  let(:user) { create(:user) }
  let(:resource) { create(:resource) }

  around { |ex| with_user_home_subdomain(user) { ex.run } }

  before do
    login_as(user, scope: :user)
  end

  context "with pre_notice" do
    let!(:protocol) { create(:reservation_protocol, resources: [resource], pre_notice: "May be bed bugs!") }

    scenario "should show warning" do
      visit new_reservation_path(resource_id: resource.id)
      expect(page).to have_content("May be bed bugs!")
    end
  end
end
