class AddsUserToList
  def self.call(args)
    finds_user = args.fetch(:finds_user) { User }
    notifies_user = args.fetch(:notifies_user) { NotifiesUser }

    user = finds_user.find_by!(username: args.fetch(:username))
    notifies_user.(user, args.fetch(:email_list_name))
    user.update_attributes(email_list_name: args.fetch(:email_list_name))
    user
  end
end