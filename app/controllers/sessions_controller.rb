class SessionsController < ApplicationController

	def new
		render 'new'
	end

	def create
			user = User.find_by_email(params[:session][:email])
			if user && user.authenticate(params[:session][:password])
				#Sign in and redirect to user's show page
				sign_in user
				redirect_back_or user
			else
				#Error message, re-render sign-in form
				flash.now[:error] = 'Invalid email/password combination.'
				render 'new'
			end
	end

	def destroy
		sign_out
		redirect_to root_path
	end

end