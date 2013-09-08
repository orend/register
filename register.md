Service Objects + No Rails Dependencies = Fastest Possible Tests
=============================================================

**TL;DR:** Extract service objects in a way that completely removes rails dependencies during test run to achieve the fastest possible test times, but more importantly - a better design.

Starting With A Fat Controller
--------------
Suppose you have a controller that's responsible for handling users signing up to a mailing list:

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

Extract Logic To A Fat Model
--------------
The logic in this controller is pretty simple, but it's still too much for a controller and should be extracted out. But where to? The word 'user' that can be found in almost every line here might suggest that we should push it to the ```User``` model. Let's try this:

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
Extact A Service Object
--------------
This is better, as the ```User``` class is now responsible for creating and updating users, but there are still a few problems. The first one is that now ```User``` is handling mailing list additions, as well as notifying the user about this. This is too many responsibilities for one class. Having an active record object handle anything more than CRUD and associations is a violation of the Single Responsibility Principle.

The second problem is that business logic in active record classes is a pain to unit test. You often need to use factories or to heavily stub out methods of the object under test (don't do that), stub all instances of the class under test (don't do that either) or hit the database in your unit tests (please don't). As a result testing active record objects can be very slow, sometimes orders of magnitude slower than testing plain ruby objects.

Now, if the code above was the entire ```User``` class and my application was small and simple I'd be perfectly happy with leaving ```User#addToEmailList``` as is. But more complex rails apps that are not groomed often enough tend to have large 'god classes' such as ```User``` or ```Order``` that attract every piece of logic that touches the model. Slow tests make an app harder to maintain and harder to work with. This is when introducing a service object is useful:

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
Inject Dependencies
--------------

We created a plain ruby object, ```AddsUserToList```, which contains the business logic from before. In the controller we call this object and not ```User``` directly.
This is an improvement, but testing this service object would require us to somehow stub ```User#find_or_create_by``` to avoid hitting the database, and probably also stub out ```NotifiesUser#run``` in order to avoid sending a real notification out. Anyway, hard coding the name of the class of your collaborator is a really bad idea since it couples your class with your collaborators forever.

The most straight forward way to decouple these classes is to inject the dependencies of ```AddsUserToList```:

```ruby
class AddsUserToList
  def self.run(username, email_list_name, creates_user = User, notifies_user = NotifiesUser)

    creates_user.find_or_create_by(username: username).tap do |user|
      notifies_user.(user, email_list_name)
      user.update_attributes(email_list_name: email_list_name)
    end
  end
end
```
Good, we can now pass any class that creates a user and any class that notifies a user, which means testing will be easier, but more importantly, that replacing, say, an email notifier with a SMS notifier will just be a matter of passing a different object to our service object. Since we supplied reasonable defaults we don't need to pass these dependencies at all, and the controller stays unchanged.

Further Decouple from ActiveRecord
--------------------------

That's almost perfect, but we still have one more thing to improve. We are still littering the service object with references to an active record class, ```User```, which means that our unit tests will have to load active record and the entire rails stack, but even worse - the entire app and its dependencies. This load time can be a few seconds for trivial rails apps, but can grow to 30 seconds for really big rails apps. Unit tests should be *fast* to run as part of your test suite but also fast to run individually, which means they should not load the rails stack or your application (also see [Corey Haines's talk](http://www.youtube.com/watch?v=bNn6M2vqxHE)
 on the subject).

But how can we both both give a reasonable default value to ```creates_user``` and make sure no active record object is getting loaded? *deferred evaluation* to the rescue. We will use ```Hash#fetch``` which receives a block that is not evaluated unless the queried key is not present. This way we are not forced to be explicit in the app code and specify the actual classes we pass in, but at the same time able to pass a mock that will replace the active record class during test time altogether; the code in the block to ```fetch``` will never get evaluated, and ```User``` won't get loaded.

Before I present the final code snippet I'd like to make another comment: when my classes contain only one public method I don't like calling it 'run', 'do' or 'perform' since these names don't convey a lot of information. In this case I'd rather call it 'call' and use ruby's shorthand notation for invoking this method. A nice bonus is being able to pass in a proc instead of the class itself if I need it. The end result looks like this:

Before:

```ruby
class EmailListController < ApplicationController
  def create
    @user = User.find_or_create_by(username: params[:username]).tap do |user|
      NotifiesUser.(user, 'blog_list')
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
The Tests
--------
```AddsUserToList``` can be tested using *true* unit tests: we can easily isolate the class under test and make sure it properly communicates with its collaborators. There is no database access, no heavy handed request stubbing and if we want to - no loading of the rails stack. In fact, I'd argue that any test that requires any of the above is not a unit test, but rather an integration test (see the entire repo [here](https://github.com/orend/register)).

```ruby
describe AddsUserToList do
  let(:creates_user) { double('creates_user') }
  let(:notifies_user) { double('notifies_user') }
  let(:user) { double('user') }
  subject(:adds_user_to_list) { AddsUserToList }

  it 'registers a new user' do
    expect(creates_user).to receive(:find_or_create_by).with(username: 'username').and_return(user)
    expect(notifies_user).to receive(:call).with(user, 'list_name')
    expect(user).to receive(:update_attributes).with(email_list_name: 'list_name')

    adds_user_to_list.('username', 'list_name', creates_user: creates_user, notifies_user: notifies_user)
  end
end
```

As you can see the test code is very similar to the the implementation code here. This is not surprising. A unit test should verify that the object under test sends the correct messages to its collaborators, and in the case of ```AddsUserToList``` we have a controller-like object, and a controller's job is to... coordinate sending messages between collaborators. Sandi Metz talks about what you should and what you shuold not test [here](http://www.confreaks.com/videos/2452-railsconf2013-the-magic-tricks-of-testing). To use her vocabulary, all we are testing here is outgoing command messages since this are the only messages this object sends.

Conclusion
----------

The 'Before' version's tests are harder to write and are sugnificantly slower. It also bundles many responsibiilties into a single class, the Controller class. The 'After' version is easier to test (we pass mocks to override the default classes). This means that in our code in ```AddsUserToList``` we can easily replace the collaborators with others if we need to, in case the requirements change. The controller has been reduced to performing the most basic task of collecting input and invoking the correct mehtods to excercise here.

Is the 'After' version better? I think it is. It's easier and faster to test, but even more importantly the collaborators are clearly defined and are treated as *roles*, not as specific implementations. As such, they can always be replaced by different implementations of the role they play. We now can concerate on the *messages* passing between the different *roles* in our system.This brings us closer to a design goal that Kent Beck stated once and we should all strive for:

>"When you can extend a system solely by adding new objects without modifying any existing objects, then you have a system that is flexible and cheap to maintain."