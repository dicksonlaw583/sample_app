require 'spec_helper'

describe "Authentication" do
  
  subject { page }

  describe "signin page" do
  	before { visit signin_path }
  	it { should have_selector('h1', text: 'Sign in') }
  	it { should have_selector('title', text: 'Sign in') }
  	let(:heading) { 'Sign in' }
    let(:page_title) { 'Sign in' }

    it_should_behave_like "all static pages"
	end

	describe "signin" do
		before { visit signin_path }

		describe "with invalid information" do
			before { click_button "Sign in" }
			it { should have_selector('title', text: 'Sign in') }
			it { should have_selector('div.alert.alert-error', text: 'Invalid') }
			describe "after visiting another page" do
				before { click_link "Home" }
				it { should_not have_selector('div.alert.alert-error') }
			end
		end

		describe "with valid information" do
			let(:user) { FactoryGirl.create(:user) }
			before do
				sign_in user
			end
			it { should have_selector('title', text: user.name) }
			it { should have_link('Users', href: users_path) }
			it { should have_link('Profile', href: user_path(user)) }
			it { should have_link('Settings', href: edit_user_path(user))}
			it { should have_link('Sign out', href: signout_path) }
			it { should_not have_link('Sign in', href: signin_path) }
			describe "after saving the user" do
				it { should have_link('Sign out') }
			end
			describe "followed by signout" do
				before { click_link "Sign out" }
				it { should have_link('Sign in') }
			end
		end
	end

	describe "authorization" do

		describe "for non-signed-in users" do
			let(:user) { FactoryGirl.create(:user) }

			describe "in Users controller" do
				describe "visiting edit page" do
					before { visit edit_user_path(user) }
					it { should have_selector('title', text: 'Sign in') }
				end

				describe "submitting to update action" do
					before { put user_path(user) }
					specify { response.should redirect_to(signin_path) }
				end

				describe "user index" do
					before { visit users_path }
					it { should have_selector('title', text: 'Sign in') }
				end

				describe "visiting following page" do
					before { visit following_user_path(user) }
					it { should have_selector('title', text: 'Sign in') }
				end

				describe "visiting followers page" do
					before { visit followers_user_path(user) }
					it { should have_selector('title', text: 'Sign in') }
				end
			end

			describe "friendly forwarding" do
				before do
					visit edit_user_path(user)
					sign_in user
				end
				describe "after signing in" do
					it { should have_selector('title', text: 'Edit user') }
				end
				describe "when signing in again" do
					before { sign_in user }
					it { should have_selector('title', text: user.name) }
				end
			end

			describe "links that should not show up" do
				it { should_not have_link('Profile') }
				it { should_not have_link('Settings') }
			end

			describe "in the Microposts controller" do
				describe "submitting to create" do
					before { post microposts_path }
					specify { response.should redirect_to(signin_path) }
				end
				describe "submitting to destroy" do
					before do
						micropost = FactoryGirl.create(:micropost)
						delete micropost_path(micropost)
					end
					specify { response.should redirect_to(signin_path) }
				end
			end
		end

		describe "for wrong user" do
			let(:user) { FactoryGirl.create(:user) }
			let(:wrong_user) { FactoryGirl.create(:user, email: "wronguser@example.com") }
			before { sign_in user }

			describe "visiting somebody else\'s edit page" do
				before { visit edit_user_path(wrong_user) }
				it { should_not have_selector('title', text: full_title('Edit user')) }
			end

			describe "submitting to update for somebody else" do
				before { put user_path(wrong_user) }
				specify { response.should redirect_to(root_path) }
			end
		end

		describe "as non-admin user" do
			let(:admin) { FactoryGirl.create(:admin) }
			let(:non_admin) { FactoryGirl.create(:user) }
			before { sign_in non_admin }

			describe "submitting DELETE request to Users#destroy action" do
				before { delete user_path(admin) }

				specify { response.should redirect_to(root_path) }
			end
		end

		describe "as signed-in user" do
			let(:user) { FactoryGirl.create(:user) }
			before { sign_in user }

			describe "submitting request to Users#new action" do
				before { get new_user_path }
				specify { response.should redirect_to(root_path) }
			end

			describe "submitting request to Users#create action" do
				before { post users_path }
				specify { response.should redirect_to(root_path) }
			end
		end

		describe "as admin user" do
			let(:admin) { FactoryGirl.create(:admin) }
			let(:adminB) { FactoryGirl.create(:admin) }
			before { sign_in admin }

			describe "admins cannot delete themselves" do
				before { delete user_path(admin) }
				specify { response.should redirect_to(root_path) }
			end

		end

	end

end
