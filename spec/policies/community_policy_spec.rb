require 'rails_helper'

describe CommunityPolicy do
  describe "permissions" do
    include_context "policy objs"

    let(:record) { community }

    permissions :update? do
      it_behaves_like "permits for commmunity admins and denies for other admins, users, and billers"
    end
  end
end