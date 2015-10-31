/**
* Include all the Jquery here for CoAbode Time Dollar Network
*/

$(function() { 

if($(window).width() > 992) {
	$('.todo-tooltip').tooltip();
	$('.todo-popover').popover();
}
	//$('#search-results').lionbars();
	$('#search-results').slimScroll({
		height:'100%'
	});

	$('.modal-display').click(function(e) {
		if($(window).width() > 992) { 
			url = $(this).attr('href');
			$("#dialog .modal-body").load(url + " #wrapper", function() {
				$("#dialog .modal-body").height($("#wrapper").height());
				$("#wrapper").css('margin-top', '0px');
			});		
			
			$("#dialog").modal();		
			e.preventDefault();
		}
			
	});
	
	$('.modal-dialog').click(function(e) {
		if($(window).width() > 992) { 
			url = $(this).attr('href');
			$("#dialog .modal-body").load(url + " #ajax-data", function() {
				$("#dialog .modal-body").height($("#wrapper").height());
				$("#wrapper").css('margin-top', '0px');
			});
			
			
			$("#dialog").modal();
			
			e.preventDefault();
		}
	});
	
	if($.trim( $('#error-dialog .modal-body').html() ).length) {
		$("#error-dialog").modal();
	}
	
	 // Toggle the dropdown menu's
     $(".dropdown .button, .dropdown button").click(function () {
            $(this).parent().find('.dropdown-slider').slideToggle('fast');
            $(this).find('span.toggle').toggleClass('active');
            return false;
        });
    
    // Close open dropdown slider/s by clicking elsewhwere on page
    $(document).bind('click', function (e) {
        if (e.target.id != $('.dropdown').attr('class')) {
            $('.dropdown-slider').slideUp();
            $('span.toggle').removeClass('active');
        }
    }); // END document.bind
		
	
	///////////////////////////////////////////////////   PROFILE FUNCTIONS  ///////////////////////////////////////////////////
	
	$('#profile_carousel').carousel(); // due to our current gem version, it does not cycle (they just fixed this for Rails)
	
	// if the current page is a profile view page
	var profile_re = /\/profiles\/\w+/
	if(profile_re.test(window.location.pathname)) { // enable div hiding for nav pills		
		function show_profile_responses() { // eventually condense function
			$('div#profile_responses_section').show();
			$('div#posted_services_section').hide();
			$('div#feedback_section').hide();
			$('div#resumes_section').hide();
			
			$('a#profile_responses_link').parent().addClass('active');
			$('a#posted_services_link').parent().removeClass('active');
			$('a#feedback_link').parent().removeClass('active');
			$('a#resumes_link').parent().removeClass('active');
			return false; // to avoid a page reload to a non-existent section
		}		
		function show_posted_services() {
			$('div#profile_responses_section').hide();
			$('div#posted_services_section').show();
			$('div#feedback_section').hide();
			$('div#resumes_section').hide();
			
			$('a#profile_responses_link').parent().removeClass('active');
			$('a#posted_services_link').parent().addClass('active');
			$('a#feedback_link').parent().removeClass('active');
			$('a#resumes_link').parent().removeClass('active');
			return false;		
		}		
		function show_feedback() {
			$('div#profile_responses_section').hide();
			$('div#posted_services_section').hide();
			$('div#feedback_section').show();
			$('div#resumes_section').hide();
			
			$('a#profile_responses_link').parent().removeClass('active');
			$('a#posted_services_link').parent().removeClass('active');
			$('a#feedback_link').parent().addClass('active');
			$('a#resumes_link').parent().removeClass('active');
			return false;			
		}
		
		function show_resumes() {
			$('div#profile_responses_section').hide();
			$('div#posted_services_section').hide();
			$('div#feedback_section').hide();
			$('div#resumes_section').show();
			
			$('a#profile_responses_link').parent().removeClass('active');
			$('a#posted_services_link').parent().removeClass('active');
			$('a#feedback_link').parent().removeClass('active');
			$('a#resumes_link').parent().addClass('active');
			return false;
		}
		
		show_profile_responses(); // firebug gives an error if this put before function declarations, but those should be hoisted...
		
		$('a#my_profile_link').addClass('selected_sidebar_link'); // so user knows where they are in terms of the sidebar
		
		var current_profile_id = window.location.pathname.substring(1).split('/')[1]; // may need to update this if ever want to access by username		
		if(current_profile_id.toString() != $('#current_profile_id_p').text().toString() && $('.carousel_pic').empty()) {
			$('#profile_carousel').css('visibility','hidden'); // count the total number of carousel images that a user has - if zero, then don't display the carousel
		}
		
		$('a#profile_responses_link').click(show_profile_responses);
		$('a#posted_services_link').click(show_posted_services);
		$('a#feedback_link').click(show_feedback); // allow interactivity by switching between the three tabs
		$('a#resumes_link').click(show_resumes);
		
		// add hover highlighting for all profile questions
		$('div.success').hover(function() { $(this).css('background-color','#E7E7E7'); },function() { $(this).css('background-color','#FFFFFF'); });
		$('div.warning').hover(function() { $(this).css('background-color','#E7E7E7'); },function() { $(this).css('background-color','#FFFFFF'); });
		$('div.unanswered_div').hover(function() { $(this).css('background-color','#E7E7E7'); },function() { $(this).css('background-color','#FFFFFF'); });
		
		//$('.question_options_button').click(function(e) {
		//	$(('#question_answer_response_' + e.target.id)).toggle('medium'); // don't need to block unless referencing e.target.href (right now I use id as a slight hack)
		//});
		
		$('.profile_response_div').children().not('.profile_response_div .question_options_caret').click(function() { // will return the div clicked on - just grab its corresponding id and parse it to get the the id to toggle
			$('#question_answer_response_' + $(this).attr('id').substring($(this).attr('id').lastIndexOf('_')+1)).toggle('medium');
		});
		
		$(".profile_response_div .question_options_button").click(function(e) { // might make more sense to keep the button available for minimizing...
			e.stopPropagation();
		});
		
		
		// trying out new profile idea: edit and privacy settings in the same area
		$('a#profile_edit_link').click(function() { 
			if($(this).text() === 'Edit Profile') {
				$(this).text('Commit Changes');
				$('a#profile_delete_link, .editable').show();
			}
			else {
				$(this).text('Edit Profile');
				$('a#profile_delete_link, .editable').hide();
				
				if($('ul.nav.nav-pills li#resumes_list_item').attr('class').indexOf('active') > -1) {
					$('ul.nav.nav-pills li#resumes_list_item').removeClass('active');
					$('div#resumes_section').hide();
					$('ul.nav.nav-pills li:first').addClass('active');
					$('div#profile_responses_section').show();
				}				
			}
			return false;
		});
		
	}
	
		
	var profile_edit_re = /\/profiles\/\w+\/answers\/\w+\/edit/
	if(profile_edit_re.test(window.location.pathname)) { // check if this is an interactive profile create page - if so, add a handler for when user leaves current page
		//alert('welcome!');
		$(window).unload(function(e) {
			//alert('going to save your current answers');
			save_current_answers(e);
			//e.preventDefault();
		});
		//window.location.load();
		
		//$('li.other_question_link a').click(function(e) { // just for now - need to make an AJAX call here to store the information
			//alert('don\'t leave!');
			//save_current_answers(e);
			//alert('saved! (hopefully)');
			//e.preventDefault(); // get rid of this when sure it worked
			//return false;
		//});
		
		/*$('.other_question a').click(function(e) {			
			save_current_answers(e);
		});
		
		$('.advance_button').click(function(e) {			
			save_current_answers(e);
		});*/
		
		$('a').click(function(e) {
			save_current_answers(e); // now adds to any link
			//return false;
		});
		
		/*$('#comments_area').keypress(function(e) {
			if(e.which == 13) { // hit the enter key
				save_current_answers(e);
				//return false;
				// advance to the next question
				//e.preventDefault();
			}		
		});
		
		$('#choices_input').keypress(function(e) {
			if(e.which == 13) { // hit the enter key
				save_current_answers(e);
				//return false;
			}		
		});*/
		
		
		function save_current_answers(e) { // instructs the backend to store all current answers in the database (AJAX call)			
			var this_profile_id = window.location.pathname.substring(1).split('/')[1];
			var this_question_id = window.location.pathname.substring(1).split('/')[3]; // there is a hidden space when splitting
			
			var form_response = null;
			var question_type = $('input#question_type').val();
			
			if(question_type == 'TEXT') {
				form_response = $('textarea#answer_response').val();
			}
			else if(question_type == 'MC') {
				form_response = $('input[type=radio]:checked').val();
			}
			else if(question_type == 'MS') {
				form_response = $('input[type=checkbox]').map(function() {
			        return ($(this).attr('checked') == 'checked' ? $(this).val() : '0');
			    }).get();
			}
			else {
				alert('ERROR: question type parameter has been tampered with - cannot submit data to server.');
				return false;
			}			
			
			/* note that contentType breaks this; trying out synchronous requesting to see if more effective */
			var ajax_data = { 
				type : "POST", /* should this be POST for older browsers? */
				url : '/profiles/' + this_profile_id + '/answers/' + this_question_id + '.json',
				dataType : 'json',
				async : false,
				data : {
					/* need to pass a _method PUT param? */
					_method : 'PUT',
					authenticity_token : $('input[name=authenticity_token]').attr('value'),
					answer : {
						response : form_response,
						comments : $('textarea#answer_comments').val()
					}
				},
				success : function(msg) {
					//alert("Data Saved: " + msg );
					//$('#last_chance').text(msg['saved']);
					if(msg['saved'] != 'ok') {
						alert(msg['saved']);
					}
				}				
			};
			$.ajax(ajax_data);
		}
	}
	
		
	// profile deletion
	var profile_delete_re = /\/profiles\/\w+\/request_delete/
	if(profile_delete_re.test(window.location.pathname)) {
		function show_report_form() { // eventually condense function
			$('div#report_problem_div').show();
			$('div#clear_data_div').hide();
			$('div#manage_blocked_list_div').hide();
			$('div#delete_profile_div').hide();
			
			$('a#report_problem_link').parent().addClass('active');
			$('a#clear_data_link').parent().removeClass('active');
			$('a#manage_blocks_link').parent().removeClass('active');
			$('a#delete_profile_link').parent().removeClass('active');
			return false; // to avoid a page reload to a non-existent section
		}		
		function show_clear_data_form() {
			$('div#report_problem_div').hide();
			$('div#clear_data_div').show();
			$('div#manage_blocked_list_div').hide();
			$('div#delete_profile_div').hide();
			
			$('a#report_problem_link').parent().removeClass('active');
			$('a#clear_data_link').parent().addClass('active');
			$('a#manage_blocks_link').parent().removeClass('active');
			$('a#delete_profile_link').parent().removeClass('active');
			return false;		
		}		
		function show_manage_blocks_form() {
			$('div#report_problem_div').hide();
			$('div#clear_data_div').hide();
			$('div#manage_blocked_list_div').show();
			$('div#delete_profile_div').hide();
			
			$('a#report_problem_link').parent().removeClass('active');
			$('a#clear_data_link').parent().removeClass('active');
			$('a#manage_blocks_link').parent().addClass('active');
			$('a#delete_profile_link').parent().removeClass('active');
			return false;			
		}
		
		function show_delete_profile_form() {
			$('div#report_problem_div').hide();
			$('div#clear_data_div').hide();
			$('div#manage_blocked_list_div').hide();
			$('div#delete_profile_div').show();
			
			$('a#report_problem_link').parent().removeClass('active');
			$('a#clear_data_link').parent().removeClass('active');
			$('a#manage_blocks_link').parent().removeClass('active');
			$('a#delete_profile_link').parent().addClass('active');
			return false;
		}
		
		show_report_form();
		
		$('a#report_problem_link, a#report_site_problem_link').click(show_report_form);
		$('a#clear_data_link, a#clear_specific_data_link').click(show_clear_data_form);
		$('a#manage_blocks_link, a#manage_blocked_lists_link').click(show_manage_blocks_form);
		$('a#delete_profile_link').click(show_delete_profile_form);
		
	}
	
	///////////////////////////////////////////////////   INTERACTIVE QUESTION CREATE MENU (new.html.erb)  ///////////////////////////////////////////////////
	
	$('.typeahead').typeahead(); // enable typeahead for all text fields that declare this as their class
	
	$('#question_question_type').change(function() {		
		var str = $('#question_question_type option:selected').val(); // determine whether to show the options div - only for MC or MS
		if(str.trim() != 'Text') {
			$('#add_choices_div').show('medium');
			//$('a#clear_choices').toggle(($('li.choices').size() > 0));
			update_current_choices();	
		}
		else {
			$('#add_choices_div').hide('medium');
		}
	});
	
	var edit_questions_re = /\/admin\/questions\/\w+\/edit/
	if(edit_questions_re.test(window.location.pathname) && $('#question_question_type option:selected').val() != 'Text') {
		$('#add_choices_div').show();
	}	
	
	// could also add the scanning of current choices to keyup (to automatically check if it exists)

	$('#choices_input').keypress(function(e) {
		if(e.which == 13) { // hit the enter key
			if($('ul.typeahead.dropdown-menu').css('display') == 'none') { // in certain browsers (e.g. Firefox), must allow the typeahead to be done, or will just add whats there
				try_to_append_choice(); // TODO: will this get annoying? would it be better to just let the user tab over if they want a pre-existing option?
			}
			e.preventDefault();
		}		
	});

	$('a#choice_submit').click(function(e) {
		try_to_append_choice();
		e.preventDefault(); // avoid actual link behavior
	});
	
	$('a.remove_choice_links').click(function(e) {
		$(this).parent('div').parent('li').remove();
		update_current_choices();
		return false;
	});
		
	
	function try_to_append_choice() { // add the choice from the text field to the options if it doesn't already exist
		var input_choice = $('#choices_input').val().trim();			
		var existing_choices = $('li.choices').map(function() {
			return $(this).find('span').text();
		}).get();
		
		if(existing_choices.indexOf(input_choice) < 0) { //!$.inArray(input_choice,existing_choices)) {
			if(input_choice.length > 0) {
				var new_choice_item = $('<li class="choices ui-state-default"><span>' + input_choice + '</span><div class="choice_links"></div></li>');				
				
				/*var edit_link = $('<a class="edit_choice_links" href="#">Edit</a>').click(function(e) {
					if($(this).text() == 'Edit') {
						$(this).text('Done');
						var span_element = $(this).parent('div').parent('li').find('span');
						span_element.replaceWith('<input class="uneditable_input modify_choice_field" type="text" value="' + span_element.text() + '" />').removeAttr('readOnly').removeAttr('readonly').removeAttr('disabled').focus().select();
					}
					else {
						$(this).text('Edit');
						var text_field_element = $(this).parent('div').parent('li').find('input[type=text]');
						text_field_element.replaceWith('<span>' + text_field_element.val() + '</span>');						
					}
					return false;
				});*/// TODO in I7 (too much of a detail right now)
				
				var remove_link = $('<a class="remove_choice_links" href="#">Remove</a>').click(function(e) {
					$(this).parent('div').parent('li').remove();
					update_current_choices();
					return false;
				});
				
				//new_choice_item.find('div.choice_links').append(edit_link); // TODO in I7
				new_choice_item.find('div.choice_links').append(remove_link);
				
				$('#current_choices').append(new_choice_item);				
				update_current_choices();
			}
			$('#choice_error_message').text('');
			$('#choices_input').val('').focus(); // need to clear and focus either way (it will already be blank, or complete from submission in the link)
		}
		else {
			$('#choice_error_message').text('ERROR: this choice already exists');
			$('#choices_input').focus()
		}
		$('a#clear_choices').show();
	}
	
	$('a#clear_choices').click(function(e) { // remove all choices that are currently there (after confirming of course)
		if(confirm('Are you sure you want to remove all existing choices?')) {
			$('#current_choices').empty();
			$('#choice_error_message').text(''); // remove any existing error
			$('#choices_input').focus().select();
			update_current_choices();
			//$('a#clear_choices').hide();
		}		
		
		e.preventDefault();
	});
	
	$('form.new_question, form.edit_question').submit(function(e) { // before submitting: 1. validate all fields; 2. if MC/MS, check that choices exist; 3. create the extra parameters for these choices, if they exist
		// check that not empty, remove html entities (or maybe this is done on server side)
		if($('#question_short_name').val().trim().length < 1) {
			alert('ERROR: you have not specified a short identifier for the question');
			return false;
		}
		if($('#question_text').val().trim().length < 1) {
			alert('ERROR: you have not specified the text for the question');
			return false;
		}
		if($('#question_question_type option:selected').val() != 'Text') { // process the other parameters - try to attach them (if everything valid)
			if($('li.choices').size() < 1) {
				alert('ERROR: you have not specified any options for a choice question');
				e.preventDefault();
			}
			else {
				var target = ((e.target.id.indexOf('edit') !== -1)?'form.edit_question':'form.new_question');
				$('li.choices span').each(function() { // append each option into a choices array that is passed in the post params (must do each one individually, as Rails will aggregate all of the hidden inputs by name by seeing the [] in the input name)				
					$('<input />').attr('type','hidden').attr('name','choices[]').attr('value',$(this).text()).appendTo(target);
				});
			}
		}
	});	
	
	// drag and drop in question create - provide the location
	$('ul.droptrue#current_choices').sortable({
		containment : '#current_choices',
		cursor : 'move',
		connectWith : 'ul' // TODO: put a delay that will smooth out the li moving
	});
	$('#current_choices').disableSelection();
	update_current_choices();
	
	function update_current_choices() {
		var total_choices = $('#current_choices').children('li.choices').size();	
		$('#current_choices').css('height',((total_choices+1)*36) + 'px');		
		$('#clear_choices').toggle((total_choices > 0)); // decide whether or not to show this button
	}
	
	//$('#current_choices_div').toggle($('#question_question_type option:selected').val() != 'Text');
	
	/////////////////////////////////////////////   INTERACTIVE FEEDBACK FORM CREATE MENU (new.html.erb)  /////////////////////////////////////////////
	
	var feedback_edit_re = /\/admin\/feedback_forms\/\d+\/edit/	
	if(window.location.pathname === '/admin/feedback_forms/new' || feedback_edit_re.test(window.location.pathname)) { // TODO: don't hardcode this
		var total_questions = $('#questions_sortable li').size() + $('#bins_sortable li').size();
	
		$('ul#questions_sortable, ul#bins_sortable').css('height',(total_questions*150) + 'px'); // calculate sizes for each element, including the outer div
		$('div#current_questions_div').css('height',(total_questions*150+10 + 'px'));
		
		$("ul.droptrue#questions_sortable, ul.droptrue#bins_sortable").sortable({ // modified since drag and drop used across multiple pages (now adds compound selector with id)
			containment : '#current_questions_div',
			cursor : 'move',
			connectWith : 'ul'
		}); // .droptrue is not a designated class name, but nice to have uniformity

		$("#questions_sortable, #bins_sortable").disableSelection();
		$('li.ui-state-default').click(function(e) { // will allow clicking anywhere in a question div to minimize or maximize the details div
			$(this).find('div').toggle('medium');
			if(e) {
				e.preventDefault();
			}
		});
		
		// enable filtering for both lists
		$('#questions_filter').keyup(function(e) {
			var input_re = new RegExp("\\w*" + $(this).val() + "\\w*",'i');
			$('#questions_sortable li').each(function() {
				$(this).toggle(input_re.test($(this).find('a').text()));
			});
		});		
		$('#feedback_questions_filter').keyup(function(e) {
			var input_re = new RegExp("\\w*" + $(this).val() + "\\w*",'i');
			$('#bins_sortable li').each(function() {
				$(this).toggle(input_re.test($(this).find('a').text()));
			});
		});
		$('#questions_filter, #feedback_questions_filter').keypress(function(e) {
			if(e.keyCode == 13) {
				return false;
			}
		});
		
		$('a#preview_new_form').click(function() { // previewing the form in a modal			
			$('h3#modal_title').text(($('#feedback_form_name').val().trim().length == 0 ? 'Your form' : $('#feedback_form_name').val().trim()));
			
			$('#preview_modal_body').empty(); // clear out all nodes currently in the modal dialog body
			var all_questions = $('#bins_sortable li');
			if(all_questions.size() == 0) {
				$('#preview_modal_body').append('<h3>You have no questions.</h3>');
			}
			else {				
				all_questions.each(function() {
					var question_text = $(this).find('p.question_text_p').text();
					$('#preview_modal_body').append('<h3>' + question_text.substring(question_text.indexOf(':')+2) + '</h3>');
								
					var question_type = $(this).find('p.question_type_p').text();
					switch(question_type.substring(question_text.indexOf(':')+2)) {
						case 'Text':
							$('#preview_modal_body').append('<textarea></textarea>');
							break;
						case 'Multiple Choice': // TODO: add class for styling to make sure label on same line
							for(var i = 0; i < 3; i++) {
								$('#preview_modal_body').append('<input type="radio" id="choice' + i + '" /><label for="choice' + i + '" >Choice ' + i + '</label>');
							}
							break;
						case 'Multiple Selection':
							for(var i = 0; i < 3; i++) {
								$('#preview_modal_body').append('<input type="checkbox" id="choice' + i + '" /><label for="choice' + i + '" >Choice ' + i + '</label>');
							}
							break;
					}
					$('#preview_modal_body').append('<p>Do you have any specific comments?</p>');
					$('#preview_modal_body').append('<textarea></textarea>');
					$('#preview_modal_body').append('<hr />');
				});
			}
			
			$('#preview_modal').modal('show');
			return false;
		});		
		$('#close_modal').click(function() {
			$('#preview_modal').modal('hide');
			return false;
		});
		
		var new_questions = []; // array of objects that represent questions
		
		$('a#create_question_link').click(function(e) { // TODO: try to hide the submit button since not needed			
			if($('#question_short_name').val().trim().length < 1) {
				alert('ERROR: you have not specified a short identifier for the new question');
				$('#question_short_name').focus();
				return false;
			}
			if($('#question_text').val().trim().length < 1) {
				alert('ERROR: you have not specified the text for the new question');
				$('#question_text').focus();
				return false;
			}
			if($('#question_question_type option:selected').val() != 'Text') { // process the other parameters - try to attach them (if everything valid)
				if($('li.choices span').size() < 1) {
					alert('ERROR: you have not specified any options for a choice question');
					$('#choices_input').focus();
					return false;
				}
			}
			
			// create a new question object and append to the list
			var new_question = {
				short_name : $('input#question_short_name').val().trim(),
				text : $('input#question_text').val().trim(),
				question_type : $('#question_question_type option:selected').val().trim(),
				choices : $('li.choices span').map(function() { return $(this).text() }).get()
			};			
			new_questions.push(new_question);
			
			// clear question form fields
			$('#question_short_name').val('');
			$('#question_text').val('');
			$('#choices_input').val('');
			$('ul#current_choices').empty(); // do I want to reset the question type to text?		
			update_current_choices();
						
			// add new question block
			var question_list_item = $('<li id="new_question_' + new_question.short_name + '" class="ui-state-default"><a href="' + new_question.short_name.replace(' ','_') + '_dropdown" class="see_question_info_links">' + new_question.short_name + '<span class="caret"></span></a><div id="' + new_question.short_name.replace(' ','_') + '_dropdown" class="question_description"></div></li>').click(function(e) { // will allow clicking anywhere in a question div to minimize or maximize the details div
				$(this).find('div').toggle('medium');
				if(e) {
					e.preventDefault();
				}
			});
			question_list_item.find('div').append('<p class="question_name_p">Question name: ' + new_question.short_name + '</p>');
			question_list_item.find('div').append('<p class="question_text_p">Question text: ' + new_question.text + '</p>');
			question_list_item.find('div').append('<p class="question_type_p">Question type: ' + new_question.question_type + '</p>');			
			if(new_question.question_type !== 'Text') { // show the choices for this question if created as MS/MC
				question_list_item.find('div').append('<p class="question_choices_p">Choices: ' + new_question.choices.join(', ') + '</p>');
			}
			$('#questions_sortable').append(question_list_item);			
			
			return false;
		});
		
		$('#new_feedback_form, form.edit_feedback_form').submit(function(e) { // validate and collect all params to process on the server side
			if($('#feedback_form_name').val().trim().length < 1) {
				alert('ERROR: you have not specified a short identifier for the feedback form');
				return false;
			} // description is optional
			
			var target = '#' + $(this).attr('id');
			var all_questions = $('#bins_sortable li');
			if(all_questions.size() < 1) {
				alert('ERROR: you have not specified any questions for this form');
				return false;
			}
			else { // user has specified questions - attach them to the parameters
				all_questions.each(function() {
					var question_number = $(this).attr('id');					
					$('<input />').attr('type','hidden').attr('name','all_questions[]').attr('value',question_number.substring(question_number.indexOf('_')+1)).appendTo(target); //'#new_feedback_form'
				});
				
				// TODO: remove this comment
				// having a hash (of question name => question object) is actually better than an array here - can use the keys to check if in the feedback form list (all_questions) on server side
				for(var i = 0; i < new_questions.length; i++) { // if user wanted to make new questions, append them to the params to create them server side
					$('<input />').attr('type','hidden').attr('name','new_questions[' + new_questions[i].short_name + '][short_name]').attr('value',new_questions[i].short_name).appendTo(target);
					$('<input />').attr('type','hidden').attr('name','new_questions[' + new_questions[i].short_name + '][text]').attr('value',new_questions[i].text).appendTo(target);
					$('<input />').attr('type','hidden').attr('name','new_questions[' + new_questions[i].short_name + '][question_type]').attr('value',new_questions[i].question_type).appendTo(target);
					
					if(new_questions[i].question_type != 'Text') { // if this was an MC/MS question, then must also append array of choices
						for(var c = 0; c < new_questions[i].choices.length; c++) {
							$('<input />').attr('type','hidden').attr('name','new_questions[' + new_questions[i].short_name + '][choices][]').attr('value',new_questions[i].choices[c]).appendTo(target);
						}
					}
				}
			}
		});
	}
	
	var reward_worker_re = /\/transactions\/reward\/\d+/	
	if(reward_worker_re.test(window.location.pathname)) {
	
		$('form#new_transaction').submit(function(e) {
			var target = $(this);
			
			$('.feedback_question_div').each(function() {				
				var question_div_id = $(this).attr('id').split('_');				
				var question_type = question_div_id[0];
				var question_id = question_div_id[2];
				var comments = $(this).find('textarea.comments').val();			
				
				var response = null;				
				if(question_type == 'TEXT') {
					response = $('textarea.response').val();
				}
				else if(question_type == 'MC') {
					//response = $('input[type=radio]:checked').val();
					response = $(this).find('input[type=radio]:checked').attr('id').split('_').slice(2).join('_');
				}
				else if(question_type == 'MS') {
					response = $(this).find('input[type=checkbox]').map(function() {
						return ($(this).attr('checked') == 'checked' ? $(this).attr('id').split('_').slice(2).join('_') : '0');
					}).get();
				}
				else {
					alert('ERROR: question type parameter has been tampered with - cannot submit data to server.');
					return false;
				}
				
				// create the extra input parameters to handle the feedback questions
				$('<input />').attr('type','hidden').attr('name','feedback_questions[' + question_id + '][id]').attr('value',question_id).appendTo(target);				
				$('<input />').attr('type','hidden').attr('name','feedback_questions[' + question_id + '][question_type]').attr('value',question_type).appendTo(target);
				if(question_type == 'MS') {
					for(var i = 0; i < response.length; i++) { // collect all response params into an array (so if commas appear in the text, won't mess up the server end)
						$('<input />').attr('type','hidden').attr('name','feedback_questions[' + question_id + '][response][]').attr('value',response[i]).appendTo(target);
					}
				}
				else {
					$('<input />').attr('type','hidden').attr('name','feedback_questions[' + question_id + '][response]').attr('value',response).appendTo(target);
				}
				$('<input />').attr('type','hidden').attr('name','feedback_questions[' + question_id + '][comments]').attr('value',comments).appendTo(target);				
			});
		});
	}
	
	
});




