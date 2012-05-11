require 'spec_helper'

describe "UserPages" do

  subject { page }

  describe "signup page" do
    before { visit signup_path }
    let(:heading) { 'Sign up' }
    let(:page_title) { 'Sign up' }

    it_should_behave_like "all static pages"
  end

  describe "profile page" do
  	let(:user) { FactoryGirl.create(:user) }
  	before { visit user_path(user) }
  	let(:heading) { user.name }
    let(:page_title) { user.name }

    it_should_behave_like "all static pages"
  end

  describe "sign up" do

  	before { visit signup_path }
  	let(:submit) { "Create my account" }

  	describe "signup with invalid information" do
  		it "should not create a user" do
  			expect { click_button submit }.not_to change(User, :count)
  		end
      describe "error messages" do
        before { click_button submit }
        it { should have_selector('title', text: 'Sign up') }
        it { should have_content('error') }
      end
  	end

  	describe "signup with valid information" do
  		before {
  			fill_in "Name", with: "Example User"
  			fill_in "Email", with: "user@example.com"
  			fill_in "Password", with: "milkybun"
  			fill_in "Confirmation", with: "milkybun"
  		}

  		it "should create a user" do
  			expect { click_button submit }.to change(User, :count).by(1)
  		end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('user@example.com') }
        it { should have_selector('title', text: user.name) }
        it { should have_selector('div.alert.alert-success', text:'Welcome') }
      end
  	end
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before {
      sign_in user
      visit edit_user_path(user)
    }

    describe "page" do
      let(:heading) { "Update your profile" }
      let(:page_title) { "Edit user" }
      it_should_behave_like "all static pages"
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }
      it { should have_content('error') }
    end

    describe "with valid information" do
      let(:new_name) { "New name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name", with: new_name
        fill_in "Email", with: new_email
        fill_in "Password", with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save changes"
      end
      it { should have_selector('title', text: new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { user.reload.name.should  == new_name }
      specify { user.reload.email.should == new_email }
    end
  end
end
