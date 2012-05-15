require 'spec_helper'

describe Relationship do
  
	let(:follower) { FactoryGirl.create(:user) }
	let(:followed) { FactoryGirl.create(:user) }
	let(:relationship) { follower.relationships.build(followed_id: followed.id) }

	subject { relationship }
	it { should be_valid }

	describe "accessible attributes" do
		it "should not allow access to follower_id" do
			expect do
				Relationship.new(follower_id: follower.id)
			end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
		end
	end

	describe "follower methods" do
		before { relationship.save }

		it { should respond_to(:follower) }
		it { should respond_to(:followed) }
		its(:follower) { should == follower }
		its(:followed) { should == followed }
	end

	describe "validations" do
		describe "follower should not be nil" do
			before { relationship.follower_id = nil }
			it { should_not be_valid }
		end

		describe "followed should not be nil" do
			before { relationship.followed_id = nil }
			it { should_not be_valid }
		end
	end

	describe "dependence on users" do
		before { relationship.save }

		it "should disappear if following side is destroyed" do
			follower.destroy
			Relationship.find_by_id(relationship.id).should be_nil
		end

		it "should disappear if followed side is destroyed" do
			followed.destroy
			Relationship.find_by_id(relationship.id).should be_nil
		end
	end

end
