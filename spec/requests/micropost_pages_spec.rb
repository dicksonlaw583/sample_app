require 'spec_helper'

describe "Micropost pages" do
  
	subject { page }
	let(:user) { FactoryGirl.create(:user) }
	before { sign_in user }

	describe "micropost creation" do
		before { visit root_path }

		describe "with invalid information" do
			it "should not create a micropost" do
				expect { click_button "Post" }.should_not change(Micropost, :count)
			end

			describe "error messages" do
				before { click_button "Post" }
				it { should have_content('error') }
			end
		end

		describe "with valid information" do
			before { fill_in 'micropost_content', with: "Lorem ipsum" }

			it "should create a micropost" do
				expect { click_button "Post"}.should change(Micropost, :count).by(1)
			end
		end
	end

	describe "micropost destruction" do
		before { FactoryGirl.create(:micropost, user: user) }
		describe "as correct user" do
			before { visit root_path }
			it "should delete a micropost" do
				expect { click_link "delete" }.should change(Micropost, :count).by(-1)
			end
		end
		describe "as wrong user" do
			let(:wrong_user) { FactoryGirl.create(:user) }
			let(:wrong_post) { FactoryGirl.create(:micropost, user: wrong_user) }
			before { visit user_path(wrong_user) }
			it { should_not have_link("delete") }
		end
	end

	describe "micropost plurals" do
    describe "0 posts" do
      before { visit root_path }
      it { should have_selector('span', text: '0 microposts') }
    end
    describe "1 post" do
      before {
        FactoryGirl.create(:micropost, user: user)
        visit root_path
      }
      it { should have_selector('span', text: '1 micropost') }
    end
    describe "2 posts" do
      before {
        FactoryGirl.create(:micropost, user: user)
        FactoryGirl.create(:micropost, user: user)
        visit root_path
      }
      it { should have_selector('span', text: '2 microposts') }
    end
  end

  describe "micropost pagination" do
  	let(:user) { FactoryGirl.create(:user)}
  end

end
