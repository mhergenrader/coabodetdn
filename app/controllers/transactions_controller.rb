class TransactionsController < ApplicationController
	authorize_resource
	
	
	
	def admin
		@page = params[:page]
		@transactions = Transaction.all
		
		if @page != nil #make up pages that you would think the admin would benefit from seeing.
			case @page #which syscall i mean page to display
				when 'analytics'
					#todo for cynthia lee
					
			
					#  opts = { :width => 700, :height => 400, :title => 'Monthly Coffee Production by Country', :vAxis => {:title => 'Cups'}, :hAxis => {:title => 'Month'}, :seriesType => 'bars', :series => {'5' => {:type => 'line'}} }
					  
					  @size_of_economy = Transaction.sum("amount", :conditions => ['is_system = ?',true])
					  @total_num_transactions = Transaction.count()
					  @total_volume_td = Transaction.sum('amount')
					  @avg_td_per_transaction = Transaction.average('amount')
					  
					  
					  #number of transactions over time
					  #num Transactions per day
					  today = Date.today
					  ntpd = GoogleVisualr::DataTable.new	  
					  ntpd.new_column('string', 'Day' ) 
					  ntpd.new_column('number', 'Transactions' )
					  ntpd.add_rows([
						[(Date.today() - 6.days).to_s(:db), Transaction.count(:conditions => ['created_at >= ? and created_at < ?', Date.today() - 6.days, Date.today() - 5.days]) ],
						[(Date.today() - 5.days).to_s(:db), Transaction.count(:conditions => ['created_at >= ? and created_at < ?', Date.today() - 5.days, Date.today() - 4.days]) ],
						[(Date.today() - 4.days).to_s(:db), Transaction.count(:conditions => ['created_at >= ? and created_at < ?', Date.today() - 4.days, Date.today() - 3.days]) ],
						[(Date.today() - 3.days).to_s(:db), Transaction.count(:conditions => ['created_at >= ? and created_at < ?', Date.today() - 3.days, Date.today() - 2.days]) ],
						[(Date.today() - 2.days).to_s(:db), Transaction.count(:conditions => ['created_at >= ? and created_at < ?', Date.today() - 2.days, Date.today() - 1.days]) ],
						[(Date.today() - 1.days).to_s(:db), Transaction.count(:conditions => ['created_at >= ? and created_at < ?', Date.today() - 1.days, Date.today()]) ],
						[Date.today().to_s(:db), Transaction.count(:conditions => ['created_at >= ? and created_at < ?', Date.today(), Date.today() + 1.days]) ]
					])
					ntpd_opts = { :width => 600, :height => 240, :title => 'Transactions Per Day', :hAxis => { :title => 'Day', :titleTextStyle => {:color => 'red'}} }
					@ntpd_chart = GoogleVisualr::Interactive::ColumnChart.new(ntpd, ntpd_opts)
					
					#average td per transaction
					vtpd = GoogleVisualr::DataTable.new
					vtpd.new_column('string', 'Day')
					vtpd.new_column('number', 'Time Dollars')
					vtpd.new_column('number', 'Average TD per Transaction')
					vtpd.add_rows([
						[(Date.today() - 6.days).to_s(:db), Transaction.sum('amount', :conditions => ['created_at >= ? and created_at < ?', Date.today() - 6.days, Date.today() - 5.days]), (Transaction.average('amount', :conditions => ['created_at >= ? and created_at < ?', Date.today() - 6.days, Date.today() - 5.days])).to_f ], 							
						[(Date.today() - 5.days).to_s(:db), Transaction.sum(:'amount', :conditions => ['created_at >= ? and created_at < ?', Date.today() - 5.days, Date.today() - 4.days]), (Transaction.average(:'amount', :conditions => ['created_at >= ? and created_at < ?', Date.today() - 5.days, Date.today() - 4.days])).to_f ],
						[(Date.today() - 4.days).to_s(:db), Transaction.sum(:'amount', :conditions => ['created_at >= ? and created_at < ?', Date.today() - 4.days, Date.today() - 3.days]), (Transaction.average(:'amount', :conditions => ['created_at >= ? and created_at < ?', Date.today() - 4.days, Date.today() - 3.days])).to_f ],
						[(Date.today() - 3.days).to_s(:db), Transaction.sum(:'amount', :conditions => ['created_at >= ? and created_at < ?', Date.today() - 3.days, Date.today() - 2.days]), (Transaction.average(:'amount', :conditions => ['created_at >= ? and created_at < ?', Date.today() - 3.days, Date.today() - 2.days])).to_f ],
						[(Date.today() - 2.days).to_s(:db), Transaction.sum(:'amount', :conditions => ['created_at >= ? and created_at < ?', Date.today() - 2.days, Date.today() - 1.days]), (Transaction.average(:'amount', :conditions => ['created_at >= ? and created_at < ?', Date.today() - 2.days, Date.today() - 1.days])).to_f ],
						[(Date.today() - 1.days).to_s(:db), Transaction.sum(:'amount', :conditions => ['created_at >= ? and created_at < ?', Date.today() - 1.days, Date.today()]), (Transaction.average(:'amount', :conditions => ['created_at >= ? and created_at < ?', Date.today() - 1.days, Date.today()])).to_f ],
						[(Date.today()).to_s(:db), Transaction.sum(:'amount', :conditions => ['created_at >= ? and created_at < ?', Date.today(), Date.today() + 1.days]), (Transaction.average(:'amount', :conditions => ['created_at >= ? and created_at < ?', Date.today(), Date.today() + 1.days])).to_f ]
					  ] )

					  vtpd_opts = { :width => 700, :height => 400, :title => 'Total Volume Time Dollars Moved Per Day', :vAxis => {:title => 'Time Dollars'}, :hAxis => {:title => 'Day'}, :seriesType => 'bars', :series => {'1' => {:type => 'line'}} }
					@vtpd_chart = GoogleVisualr::Interactive::ComboChart.new(vtpd, vtpd_opts)					
					
					#number of new users per day
					nupd = GoogleVisualr::DataTable.new	  
					  nupd.new_column('string', 'Day' ) 
					  nupd.new_column('number', 'New Users' )
					  nupd.add_rows([
						[(Date.today() - 6.days).to_s(:db), User.count(:conditions => ['created_at >= ? and created_at < ?', Date.today() - 6.days, Date.today() - 5.days]) ],
						[(Date.today() - 5.days).to_s(:db), User.count(:conditions => ['created_at >= ? and created_at < ?', Date.today() - 5.days, Date.today() - 4.days]) ],
						[(Date.today() - 4.days).to_s(:db), User.count(:conditions => ['created_at >= ? and created_at < ?', Date.today() - 4.days, Date.today() - 3.days]) ],
						[(Date.today() - 3.days).to_s(:db), User.count(:conditions => ['created_at >= ? and created_at < ?', Date.today() - 3.days, Date.today() - 2.days]) ],
						[(Date.today() - 2.days).to_s(:db), User.count(:conditions => ['created_at >= ? and created_at < ?', Date.today() - 2.days, Date.today() - 1.days]) ],
						[(Date.today() - 1.days).to_s(:db), User.count(:conditions => ['created_at >= ? and created_at < ?', Date.today() - 1.days, Date.today()]) ],
						[Date.today().to_s(:db), User.count(:conditions => ['created_at >= ? and created_at < ?', Date.today(), Date.today() + 1.days]) ]
					])
					nupd_opts = { :width => 600, :height => 240, :title => 'New Users Per Day', :hAxis => { :title => 'Day', :titleTextStyle => {:color => 'red'}} }
					@nupd_chart = GoogleVisualr::Interactive::ColumnChart.new(nupd, nupd_opts)

				
					  
					return
				when 'search'
					#todo for cynthia lee, you'd probably want to search for a particular transaction
					return
				when 'view_user'
					if(params[:user])
						#find the user
						@u = User.find_by_email(params[:user])
					end
					return
					
				else
					#this case needs to be validated (like show a 404 page or something)
					#todo for cynthia lee
					return
				end
		else
			#todo for cynthia lee... if there is no page, do what? It already shows all the transactions
			return
		end
	end



	
	
  # GET /transactions
  # GET /transactions.json
  def index
   # @transactions = Transaction.all
	@transactions = current_user.incoming_transactions + current_user.outgoing_transactions 
	@time_dollars = current_user.time_dollars
    
	respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @transactions }
    end
  end

  # GET /transactions/1
  # GET /transactions/1.json
  def show
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @transaction }
    end
  end

  # GET /transactions/new
  # GET /transactions/new.json
  def new
    @transaction = Transaction.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @transaction }
    end
  end

  # GET /transactions/1/edit
  def edit
    @transaction = Transaction.find(params[:id])
  end
  
  def reward
	@job_applicant = JobApplicant.find(params[:id])
	@transaction = Transaction.new
	@transaction.job = @job_applicant.job
	@transaction.amount = @job_applicant.job.price
	@transaction.to = @job_applicant.applicant
	
	# create a feedback form
	all_questions = Question.select('id,short_name,text,question_type').all
	@feedback_questions = [] # array of specialized hashes
	@feedback_questions_hash = {}
	
	peer_feedback_form = FeedbackForm.select('id').where('form_type = ?',FeedbackForm::PEER_TO_PEER_TYPE).first # TODO: there can exist multiple copies of this later
	if peer_feedback_form.nil?
		redirect_to root_url
		return
	end # "for now" error checking
	
	# be sure to grab the actual peer to peer feedback form (can have multiple later)
	feedback_questions = FeedbackQuestion.select('question_id,updated_at').where('feedback_form_id = ?',peer_feedback_form.id).all
	feedback_questions.each do |q|
		@feedback_questions_hash[q.question_id] = q.updated_at.to_f
	end
	
	all_questions.each do|question|
		if @feedback_questions_hash.keys.include?(question.id)
			modified_question = {:id => question.id,:short_name => question.short_name,:text => question.text,:question_type => question.question_type,:updated_at => @feedback_questions_hash[question.id]}
			@feedback_questions << modified_question
		end
	end
	
	@feedback_questions.sort!{|a,b| a[:updated_at]<=>b[:updated_at]}
	#end with create feedback form
	
	respond_to do |format|
		format.html
		format.json { render json: @transaction }
	end
  end
  
  

  # POST /transactions
  # POST /transactions.json
  def create
	@params = params	
    @transaction = Transaction.new(params[:transaction])
	@transaction.from = current_user
	@job_applicant = JobApplicant.find_by_service_id(@transaction.service_id, :conditions => ["applicant_id = ?", @transaction.receiver_id])
	if not @job_applicant.nil?
		@job_applicant.is_paid = true
	end
	
	@feedback_questions = params[:feedback_questions] # store all answered feedback questions
	@errors = ''
	
	@feedback_questions.each do |k,v|
		# check if the question exists so don't store faulty data
		question = Question.select('id').where('id = ?',k).first
		if question.nil?
			@errors << '|| bad question id ' + k
			next
		end
		if v[:question_type].nil?
			@errors << '|| bad question type for id ' + k
			next
		end
		response = _get_user_response(v[:question_type],v[:response])
		if response.nil?
			@errors << '|| could not get response for id ' + k
			next	
		end
		about_user = Profile.where('user_id = ?',@transaction.receiver_id).first
		if about_user.nil?
			@errors << '|| could not find about user ' + @transaction.receiver_id
			next
		end
		
		comments = (v[:comments] || '') #(v[:comments].nil? ? '' : v[:comments])
		respondent = Profile.where('user_id = ?',current_user.id).first
		
		feedback_answer = FeedbackAnswer.new(:response => response, :comments => comments, :respondent_id => respondent.id, :about_id => about_user.id, :question_id => question.id, :job_id => @transaction.service_id)
		feedback_answer.save!
	end
	
    respond_to do |format|
	  if not @job_applicant.nil?
		  if @transaction.save and @job_applicant.save
			format.html { redirect_to @transaction, notice: 'Transaction was successfully created.', notice: 'Worker was successfully paid.' }
			format.json { render json: @transaction, status: :created, location: @transaction }
		  else
			format.html { render action: "new" }
			format.json { render json: @transaction.errors, status: :unprocessable_entity }
		  end
	  else
		if @transaction.save
			format.html { redirect_to @transaction, notice: 'Transaction was successfully created.', notice: 'Worker was successfully paid.' }
			format.json { render json: @transaction, status: :created, location: @transaction }
		else
			format.html { render action: "new" }
			format.json { render json: @transaction.errors, status: :unprocessable_entity }
		end
	  end
    end
  end

  # PUT /transactions/1
  # PUT /transactions/1.json
  def update
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      if @transaction.update_attributes(params[:transaction])
        format.html { redirect_to @transaction, notice: 'Transaction was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/1
  # DELETE /transactions/1.json
  def destroy
    @transaction = Transaction.find(params[:id])
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to transactions_url }
      format.json { head :ok }
    end
  end
  
  
  private
  
  def _get_user_response(question_type,response)
	case question_type
		when "TEXT"
			response # this could be empty string from form (so don't have to assign it explicitly) - don't need to check nil			
		when "MC"
			(response || '') #(response.nil? ? '' : response) # if nothing selected, first part of ternary operator will return nil - convert this to empty string
		when "MS"				
			ms_values = response.map{ |i| i != '0' ? i : nil }.compact # first grab all multiple selection values, if any; remove any nils inside; done backwards like this so labels will tie to check box elements	
			(ms_values.empty? ? '' : ms_values.join('##'))	  		
		else
			nil # error occurred - question is not of designated type
	end
  end
  
  
  
  
end
