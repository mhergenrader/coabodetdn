module MessagesHelper
	def message_show_sent_path(message)
		return "/messages/sent/" + message.id.to_s
	end
end
