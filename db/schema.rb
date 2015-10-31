# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120427064640) do

  create_table "answers", :force => true do |t|
    t.string   "response"
    t.string   "comments"
    t.integer  "profile_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "dispute_id"
  end

  add_index "answers", ["dispute_id"], :name => "index_answers_on_dispute_id"
  add_index "answers", ["profile_id"], :name => "index_answers_on_profile_id"
  add_index "answers", ["question_id"], :name => "index_answers_on_question_id"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "choices", :force => true do |t|
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "disputes", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.integer  "offender_id"
    t.integer  "service_id"
    t.string   "description"
    t.boolean  "is_resolved"
  end

  add_index "disputes", ["offender_id"], :name => "index_disputes_on_offender_id"
  add_index "disputes", ["owner_id"], :name => "index_disputes_on_owner_id"
  add_index "disputes", ["service_id"], :name => "index_disputes_on_service_id"

  create_table "feedback_answers", :force => true do |t|
    t.string   "response"
    t.string   "comments"
    t.integer  "respondent_id"
    t.integer  "about_id"
    t.integer  "question_id"
    t.integer  "job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feedback_answers", ["about_id"], :name => "index_feedback_answers_on_about_id"
  add_index "feedback_answers", ["job_id"], :name => "index_feedback_answers_on_job_id"
  add_index "feedback_answers", ["question_id"], :name => "index_feedback_answers_on_question_id"
  add_index "feedback_answers", ["respondent_id"], :name => "index_feedback_answers_on_respondent_id"

  create_table "feedback_forms", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "form_type"
  end

  add_index "feedback_forms", ["created_by"], :name => "index_feedback_forms_on_created_by"
  add_index "feedback_forms", ["id"], :name => "index_feedback_forms_on_id"
  add_index "feedback_forms", ["name"], :name => "index_feedback_forms_on_name"
  add_index "feedback_forms", ["updated_by"], :name => "index_feedback_forms_on_updated_by"

  create_table "feedback_questions", :force => true do |t|
    t.integer  "question_id"
    t.integer  "feedback_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feedback_questions", ["feedback_form_id", "question_id"], :name => "index_feedback_questions_on_feedback_form_id_and_question_id"
  add_index "feedback_questions", ["question_id", "feedback_form_id"], :name => "index_feedback_questions_on_question_id_and_feedback_form_id"

  create_table "folders", :force => true do |t|
    t.integer  "user_id"
    t.integer  "parent_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", :force => true do |t|
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "image"
    t.boolean  "profile_picture"
    t.string   "image_description"
  end

  add_index "images", ["name"], :name => "index_images_on_name"
  add_index "images", ["profile_id"], :name => "index_images_on_profile_id"

  create_table "inclusions", :force => true do |t|
    t.integer  "question_id"
    t.integer  "choice_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inclusions", ["choice_id", "question_id"], :name => "index_inclusions_on_choice_id_and_question_id"
  add_index "inclusions", ["question_id", "choice_id"], :name => "index_inclusions_on_question_id_and_choice_id"

  create_table "job_applicants", :force => true do |t|
    t.integer  "service_id"
    t.integer  "applicant_id"
    t.boolean  "is_hired"
    t.boolean  "is_paid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jobs", :force => true do |t|
    t.string   "title"
    t.float    "price"
    t.text     "description"
    t.date     "when"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "address"
    t.boolean  "is_accepted"
    t.integer  "num_of_workers"
    t.integer  "accept_counter"
    t.integer  "category_id"
  end

  create_table "message_copies", :force => true do |t|
    t.integer  "recipient_id"
    t.integer  "message_id"
    t.integer  "folder_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "read"
  end

  create_table "messages", :force => true do |t|
    t.integer  "from"
    t.string   "title"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "read"
    t.integer  "thread_id"
  end

  create_table "notification_templates", :force => true do |t|
    t.text     "template",      :limit => 255
    t.integer  "max_arguments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "method"
    t.string   "to_attr"
    t.string   "link_attr"
    t.string   "model"
    t.boolean  "user_id"
  end

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.integer  "lookup_id"
    t.text     "message",     :limit => 255
    t.string   "inner_links"
    t.integer  "link_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "template_id"
    t.boolean  "read"
  end

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["id"], :name => "index_profiles_on_id"
  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"

  create_table "questions", :force => true do |t|
    t.string   "short_name"
    t.string   "text"
    t.string   "question_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.integer  "min_required"
    t.integer  "max_acceptable"
    t.integer  "updated_by"
    t.string   "domain"
  end

  add_index "questions", ["created_by"], :name => "index_questions_on_created_by"
  add_index "questions", ["id"], :name => "index_questions_on_id"
  add_index "questions", ["short_name"], :name => "index_questions_on_short_name"
  add_index "questions", ["updated_by"], :name => "index_questions_on_updated_by"

  create_table "relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["followed_id"], :name => "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id", "followed_id"], :name => "index_relationships_on_follower_id_and_followed_id", :unique => true
  add_index "relationships", ["follower_id"], :name => "index_relationships_on_follower_id"

  create_table "resumes", :force => true do |t|
    t.string   "name"
    t.string   "resume_description"
    t.string   "resume"
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resumes", ["name"], :name => "index_resumes_on_name"
  add_index "resumes", ["profile_id"], :name => "index_resumes_on_profile_id"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transactions", :force => true do |t|
    t.integer  "service_id"
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_system"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username",                              :default => "", :null => false
    t.string   "first_name",                            :default => "", :null => false
    t.string   "middle_name",                           :default => ""
    t.string   "last_name",                             :default => "", :null => false
    t.string   "ethnicity",                             :default => "", :null => false
    t.date     "date_of_birth"
    t.string   "state",                                 :default => "", :null => false
    t.string   "city",                                  :default => "", :null => false
    t.integer  "zip_code"
    t.string   "confirmed_at"
    t.datetime "confirmation_sent_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

end
