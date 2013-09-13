class AddsUserToList
  def self.call(args)
    creates_user = args.fetch(:creates_user) { User }
    notifies_user = args.fetch(:notifies_user) { NotifiesUser }

    creates_user.find_or_create_by(username: args.fetch(:username)).tap do |user|
      notifies_user.(user, args.fetch(:email_list_name))
      user.update_attributes(email_list_name: args.fetch(:email_list_name))
    end
  end
end