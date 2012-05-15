require 'spec_helper'

describe Micropost do
  let(:user) { FactoryGirl.create(:user) }
  before do
  	@micropost = user.microposts.build(content: "Lorem ipsum")
  end

  subject { @micropost }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should be_valid }
  its(:user) { should == user }

  describe "when user_id is not present" do
  	before { @micropost.user_id = nil }
  	it { should_not be_valid }
  end

  describe "when there is no content" do
  	before { @micropost.content = " " }
  	it { should_not be_valid }
  end

  describe "when content is too long" do
  	before { @micropost.content = "a" * 141 }
  	it { should_not be_valid }
  end

  describe "accessible attributes" do
  	it "should not allow access to user_id" do
  		expect do
  			Micropost.new(user_id: user.id)
  		end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
  	end
  end

  describe "from_users_followed_by" do
    let(:user) { FactoryGirl.create(:user) }
    let(:userA) { FactoryGirl.create(:user) }
    let(:userB) { FactoryGirl.create(:user) }

    before { user.follow!(userA) }

    let(:my_post) { user.microposts.create!(content: "foo") }
    let(:followed_post) { userA.microposts.create!(content: "bar") }
    let(:unfollowed_post) { userB.microposts.create!(content: "Waahoo") }

    subject { Micropost.from_users_followed_by(user) }

    it { should include(my_post) }
    it { should include(followed_post) }
    it { should_not include(unfollowed_post) }
  end

end