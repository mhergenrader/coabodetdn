class DisputesController < ApplicationController
	authorize_resource
	
	def index
		@disputes = Dispute.all
		respond_to do |format|
		  format.html # index.html.erb
		  format.json { render json: @disputes }
		end
	end
	
	def new
		@dispute = Dispute.new
		
		respond_to do |format|
		  format.html # new.html.erb
		  format.json { render json: @dispute }
		end
	end
	
	def create
		@params = params
		
		@dispute = Dispute.new(:service_id => params[:dispute][:service_id], :offender_id => params[:dispute][:offender_id], :description => params[:dispute][:description])
		@a = params[:dispute][:description]
		@dispute.owner_id = current_user.id
		@dispute.is_resolved = false
		@dispute.save!
		
		respond_to do |format|
		  if @dispute.save
			format.html { redirect_to @dispute, notice: 'Dispute was successfully created.' }
			format.json { render json: @dispute, status: :created, location: @dispute }
		  else
			format.html { render action: "new" }
			format.json { render json: @dispute.errors, status: :unprocessable_entity }
		  end
		end
	end
	
	def edit
		@dispute = Dispute.find(params[:id])
	end
	
	def show
		@dispute = Dispute.find(params[:id])

		respond_to do |format|
		  format.html # show.html.erb
		  format.json { render json: @dispute }
		end
	end
	
	def update
		@dispute = Dispute.find(params[:id])

		respond_to do |format|
		  if @dispute.update_attributes(params[:dispute])
			format.html { redirect_to @dispute, notice: 'Transaction was successfully updated.' }
			format.json { head :ok }
		  else
			format.html { render action: "edit" }
			format.json { render json: @dispute.errors, status: :unprocessable_entity }
		  end
		end
	end
	
	def destroy
		@dispute = Dispute.find(params[:id])
		@dispute.destroy

		respond_to do |format|
		  format.html { redirect_to disputes_url }
		  format.json { head :ok }
		end
	end
	
	def admin_list
		@disputes = Dispute.all
	end
	
	def dispute_list
		@disputes = Dispute.where(:owner_id == current_user.id).all | Dispute.where(:offender_id == current_user.id).all
	end
end
