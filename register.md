Suppose you have a controller that's responsible for handling users signing up to a mailing list:
Fat Controller
--------------

```ruby
class EmailListController < ApplicationController
  def create
    @user = User.find_or_create_by(username: params[:username]).tap do |user|
      NotifiesUser.run(user, 'blog_list')
      user.update_attributes(email_list_name: 'blog_list')
    end
    render json: @user
  end
end

```
We first find the user or create it if it doesn't exist. Then we notify the user it was added to the mailing list via ```NotifiesUser``` (probably asking her to confirm). We update the user record with the name of the mailing list and then render the user as a json.

Fat Model
--------------
The logic in this controller is pretty simple, but it's still too much for a controller and should be extracted out. But where to? The word 'user' that can be found in almost every line here might suggest that we push it to the ```User``` model. Let's try this:

```ruby
class EmailListController < ApplicationController
  def create
    @user = User.addToEmailList(params[:username], 'blog_list')
    render json: @user
  end
end

```
```ruby
class User < ActiveRecord::Base
  validates_uniqueness_of :username
  
  def self.addToEmailList(username, email_list_name)
  	User.find_or_create_by(username: username).tap do |user|
      NotifiesUser.run(user, 'blog_list')
      user.update_attributes(email_list_name: 'blog_list')
    end
  end
end
```
Service Object
--------------
This is better, the ```User``` class knows better about creating and updating users, but there are still a few problems. The first one is that having ```User``` handle mailing list additions, and specifically notifying the user about this with ```NotifiesUser```. In fact, having an active record object handle anything more than CRUD and associations is a violation of the Single Responsibility Principle.

The second problem is that business logic in active record classes are a pain to unit test. You often need factories or to heavily stub out methods of the object under test (don't do that), stub all instances of the class under test (don't do that either) or hit the database in your unit tests (please don't). As a result testing active record objects can be very slow, sometimes orders of magnitude slower than testing plain ruby objects.

Now, if the code above was the entire ```User``` class and my application was small and simple I'd be perfectly happy with leaving ```User#addToEmailList``` as is. But more complex rails apps that are not groomed often enough tend to have large 'god classes' such as ```User``` or ```Order``` that attract every piece of logic that even touches these classes, which makes these kind of apps very hard to maintain. This is when introducing a service object is useful:

```ruby
class EmailListController < ApplicationController
  def create
    @user = AddsUserToList.run(params[:username], 'blog_list')
    render json: @user
  end
end
```
```ruby
class AddsUserToList
  def self.call(username, email_list_name)
    User.find_or_create_by(username: username).tap do |user|
      NotifiesUser.run(user, 'blog_list')
      user.update_attributes(email_list_name: 'blog_list')
    end
  end
end
```
Dependency Injection
--------------
This is an improvement, but testing this service object would require us to somehow stub ```User#find_or_create_by``` to avoid hitting the database, and probably also stub out ```NotifiesUser#run``` in order to avoid sending a real notification out. Anyway, hard coding the name of the class of your collaborator is a really bad idea since it couples your class and your collaborators forever. 

The most straight forward way to decouple these classes is to inject the dependencies of ```AddsUserToList```:

```ruby
class AddsUserToList
  def self.call(username, email_list_name, creates_user = User, notifies_user = NotifiesUser)

    creates_user.find_or_create_by(username: username).tap do |user|
      notifies_user.(user, email_list_name)
      user.update_attributes(email_list_name: email_list_name)
    end
  end
end
```
Good, we can now pass any class that creates a user and any class that notifies a user, which means testing will be easier but more importantly that replacing, say, an email notifier with a SMS notifier will just be a matter of passing a different object to our service object. Since we supplied reasonable defaults we don't need to pass these dependencies at all, and the controller stays unchanged.

That's almost perfect, but we still have one more thing to improve. We are still littering the service object with an active record class, which means that our unit tests will have to load active record and the entire rails stack. This can be very slow depending on the dependencies of your app. Ideally the unit tests should be able to run without loading rails or your app.

But how can we both give reasonable defaults and make sure no active record object is getting loaded? *deferred evaluation* to the rescue. We will use ```Hash#fetch``` which receives a block that is not evaluated unless the queried key is not present.

Another comment, when my classes contain only one public method I don't like calling it 'run', 'do' or 'perform' since these names don't convey a lot of information. In this case I'd rather call it 'call' and use ruby's shorthand notation for invoking this method. A nice bonus is being able to pass in a proc instead of the class itself if I need it. The end result looks like this:

Further Decouple from ActiveRecord
--------------------------
Before:

```ruby
class EmailListController < ApplicationController
  def create
    @user = User.find_or_create_by(username: params[:username]).tap do |user|
      NotifiesUser.run(user, 'blog_list')
      user.update_attributes(email_list_name: 'blog_list')
    end
    render json: @user
  end
end

```
After:

```ruby
class EmailListController < ApplicationController
  def create
    @user = AddsUserToList.(params[:username], 'blog_list')
    render json: @user
  end
end

```
```ruby
class AddsUserToList
  def self.call(username, email_list_name, params = {})
    creates_user = params.fetch(:creates_user) { User }
    notifies_user = params.fetch(:notifies_user) { NotifiesUser }

    creates_user.find_or_create_by(username: username).tap do |user|
      notifies_user.(user, email_list_name)
      user.update_attributes(email_list_name: email_list_name)
    end
  end
end
```