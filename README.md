# A Simple Tweeting App

A _step-by-step_ **tutorial** on how to implement a simple **Ruby on Rails** _web application_ that functions similarly to [Tweeter](https://twitter.com)

## Table of Contents
1. [Task](#task)
2. [Creation Instructions](#creation-instructions)
   - [Initialization](#initialization)
   - [Models](#models)
      - [Database](#models-1)
      - [Associations](#models-2)
      - [Attached image](#models-3)
   - [Routes](#routes)
   - [Views](#views)
      - [Landing page](#landing-page)
         - [Removing the links to nonexisting paths](#landing-1)
         - [Sample data generation](#landing-2)
         - [Design & Layout](#landing-3)
         - [Paging](#landing-4)
         - [Displaying the author](#landing-5)
      - [User#show](#usershow)
      - [Users#index](#usersindex)
   -

## Task

Make a web application with **Ruby on Rails** that functions similarly to [Tweeter](https://twitter.com)

You will need to implement only two models: **tweets** and **users**

A **tweet** will have `body` column of type **string**, which can't be NULL.

A **user** will have:
- a `name` column, that can't be NULL and that has a DB index (for better search performance)
- an `avatar` (attached image) with sizes: **100x100** for *thumbnali* and **300x300** for *medium* size picture

You must implement **authentication** for the **user** and add appropriate restrictions.
_You may try to authenticate the user with an **username** instead of **email**_

On your app's **website**, you should be showing:
- _all the tweets_ at the **landing** page, where each **tweet** links to it's **author** (`tweets/index`)
- **login** and **signup** screens
- a **users index** page (`users/index`)
- a **user profile** screen (`users/show`)
- an **edit user** screen, which is available only for _logged in user_ who is _the owner_ of the profile (`users/edit`)
- a **new tweet** screen, which is available only for _logged in users_ (`tweets/new`)
- an **edit tweet** screen, which is available only for _logged in user_ who is _the owner_ of the tweet (`tweets/edit`)
- a screen with *all tweets of a user* (`/users/5/tweets`)

You should also provide a `delete` action for a **tweet**, which can be _only_ performed by the _owner of the **tweet**_.

[back to top](a-simple-tweeting-app)

## Creation Instructions

### Initialization
```
rails new tweeter -T
cd tweeter
git commit -m"Initial commit"
```

### Models

<a name="models-1"></a>
1. **Database**

   Add the following gems to **Gemfile**: [devise](https://github.com/plataformatec/devise), [paperclip](https://github.com/thoughtbot/paperclip), [faker](https://github.com/stympy/faker), [fabrication](https://github.com/paulelliott/fabrication), [pry-rails](https://github.com/rweng/pry-rails), [bootstrap 4](https://github.com/twbs/bootstrap-rubygem).

   Make sure you put the new gems in their _corresponding_ groups in the Gemfile.

   When done, run `bundle install`

   ```
   bundle
   ```

   Now it's time to generate your resources:

   ```
   rails g scaffold user name:string
   rails g scaffold tweet body:string user:belongs_to
   rails g devise:install
   rails g devise user
   rails g migration add_avatar_to_users
   ```

   _Very important step_: Review & edit (where necessary) all migration files.

   It will be a good idea to:
   - add index for the **name** column in `users` table.
   - set to `not null` the **name** in `users` and the **body** in `tweets`.
   - remove all unnecessary stuff from the **devise** migration (you will use only the following devise modules: _database_authenticatable_, _registerable_, _recoverable_, _rememberable_, _trackable_, _validatable_)

   Now you can execute all migrations:

   ```
   rails db:migrate
   ```

   [back to top](a-simple-tweeting-app)

<a name="models-2"></a>
1. **Associations**

   Add the following associations to the **User** & **Tweet** models:

   ```ruby
   class User < ApplicationRecord
     has_many :tweets, dependent: :destroy
   end

   class Tweet < ApplicationRecord
     belongs_to :user
     end
   ```

   [back to top](a-simple-tweeting-app)

<a name="models-3"></a>
1. **Attached image**

   Add the **Paperclip** stuff to the **User**:

   ```ruby
   has_attached_file :avatar,
                     styles: { medium: "300x300#", thumb: "100x100#" },
                     default_url: "/images/:style/missing.png"
   ```

   Add the two **missing.png** images in the corresponding folders.

   [back to top](a-simple-tweeting-app)

### Routes

Configure the routing (in `config/router.rb`)

```ruby
Rails.application.routes.draw do
  devise_for :users

  resources :tweets, only: :index

  resources :users, only: [:index, :show, :edit, :update, :destroy] do
    resources :tweets
  end

  root to: "tweets#index"
end
```

and start your server:

```
rails s -p 3056
```

[back to top](a-simple-tweeting-app)

### Views

#### Landing page

The **landing page** for our app is the **tweets index** page. Let's go and see _how_ it looks like.

Open your app's initial page (http://localhost:3056/). You'll get _errors_, because we've limited the **tweets routes** to _only_ **index**.

<a name="landing-1"></a>
1. **Removing the links to nonexisting paths**

   Edit `app/views/tweets/index.html.erb`:

   ```html
   <h1>Tweets</h1>

   <table>
     <thead>
       <tr>
         <th>Body</th>
         <th>User</th>
         <th colspan="3"></th>
       </tr>
     </thead>

     <tbody>
       <% @tweets.each do |tweet| %>
         <tr>
           <td><%= tweet.body %></td>
           <td><%= tweet.user %></td>
         </tr>
       <% end %>
     </tbody>
   </table>
   ```

   Now if you reload the website, you will see an empty tweets page.

   [back to top](a-simple-tweeting-app)

<a name="landing-2"></a>
1. **Sample data generation**

   Let's generate some fake data, using **Fabrication** and **database seeds**.

   ```
   rails g fabrication:model user
   rails g fabrication:model tweet
   ```

   Edit the two generated files:

   ```ruby
   # spec/fabricators/user_fabricator.rb
   Fabricator(:user) do
     name { Faker::LordOfTheRings.unique.character }
     email { Faker::Internet.unique.email }
     password "123456"
   end
   ```

   ```ruby
   # spec/fabricators/tweet_fabricator.rb
     Fabricator(:tweet) do
     body { Faker::Lorem.paragraph(3) }
   end
   ```

   In `db/seeds.rb` put this:

   ```ruby
   User.destroy_all # will delete all users and all their tweets

   20.times do |i|
     user = Fabricate(:user)
     rand(10).times do
       Fabricate(:tweet, user: user)
     end
     puts "Generated #{user.name} with #{user.tweets.count} tweets"
   end
   ```

   Now run `rails db:seed`

   You should see something like:

   ```
   Generated Frodo Baggins with 7 tweets
   Generated Barliman Butterbur with 1 tweets
   Generated Shelob with 2 tweets
   Generated Denethor with 2 tweets
   Generated Peregrin Took with 4 tweets
   Generated Legolas with 8 tweets
   Generated Glorfindel with 3 tweets
   Generated Faramir with 6 tweets
   Generated Éomer with 2 tweets
   Generated Quickbeam with 8 tweets
   Generated Samwise Gamgee with 8 tweets
   Generated Beregond with 9 tweets
   Generated Tom Bombadil with 8 tweets
   Generated Meriadoc Brandybuck with 7 tweets
   Generated Galadriel with 8 tweets
   Generated Shadowfax with 4 tweets
   Generated Théoden with 3 tweets
   Generated Gimli with 1 tweets
   Generated Éowyn with 9 tweets
   Generated Treebeard with 7 tweets
   ```

   Now if you **reload** the website in the browser, you'll see the **Tweets** page _full of data_.

   [back to top](a-simple-tweeting-app)

<a name="landing-3"></a>
1. **Design & Layout**

   Now it's time to fix the design.

   Start by deleting _all the content_ in `app/assets/stylesheets/scaffolds.scss` and leave the file _empty_.

   Replace the content of `app/views/tweets/index.html.erb` with the following:

   ```html
   <h1 class="mb-4">Tweets</h1>

   <section class="tweets">
     <% @tweets.each do |tweet| %>
       <div class="card mb-3 border-primary">
         <div class="card-header">
          <%= l(tweet.created_at, format: :short) %>
         </div>
         <div class="card-body">
           <blockquote class="blockquote mb-0">
            <p><%= tweet.body %></p>
            <footer class="small text-muted">-- <%= link_to tweet.user.name, tweet.user %></footer>
           </blockquote>
         </div>
       </div>
     <% end %>
   </section>
   ```

   And in `app/views/layouts/application.html.erb` with the following:
   ```html
   <!DOCTYPE html>
   <html>
   <head>
     <title>Tweeter</title>
     <%= csrf_meta_tags %>

     <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track': 'reload' %>
     <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
   </head>

   <body>
     <div class="container mt-5">

     <% flash.each do |name, msg| %>
      <%= content_tag(:div, msg, class: "alert alert-#{name == 'notice' ? 'info' : 'danger'}") %>
     <% end %>

     <%= yield %>

     <footer class="footer">
      <p>© The Tweet Monsters 2017</p>
     </footer>
     </div>
   </body>
   </html>
   ```

   In the **TweetsController** cleanup all _json_ responses and change the **index** method like so:

   ```ruby
   def index
     @tweets = Tweet.eager_load(:user).all
   end
   ```

   This will load all **users** data in the result and will prevent additional DB requests later.

   Now it's time to check what we've acheived and **refresh** the website.

   [back to top](a-simple-tweeting-app)

<a name="landing-4"></a>
1. **Paging**

   Add the [kaminari](https://github.com/kaminari/kaminari) and [bootstrap4-kaminari-views](https://github.com/KamilDzierbicki/bootstrap4-kaminari-views) gems to your **Gemfile**.

   Install them with `bundle install` and make the following changes in `tweets`:

   1. Change the `index` action in `TweetsController`:

      ```ruby
      def index
        @tweets = Tweet.eager_load(:user).page(params[:page]).per(3)
      end
      ```

    1. And add the following line at the end of `app/views/tweets/index.html.erb`:

       ```html
       <%= paginate @tweets, window: 1, outer_window: 1, theme: 'twitter-bootstrap-4' %>
       ```

       [back to top](a-simple-tweeting-app)

<a name="landing-5"></a>
1. **Displaying the author**

   Create a new file `app/views/tweets/_tweet.html.erb` and put inside the _html_ for the **tweet**, that we used in `app/views/tweets/index.html.erb`:

   ```html
   <div class="card mb-3 border-primary">
     <div class="card-header">
       <%= l(tweet.created_at, format: :short) %>
     </div>
     <div class="card-body">
       <blockquote class="blockquote mb-0">
         <p><%= tweet.body %></p>
         <footer class="small text-muted">-- <%= link_to tweet.user.name, tweet.user %></footer>
       </blockquote>
     </div>
   </div>
   ```

   Now _substitude_ all these lines in `app/views/tweets/index.html.erb` with just `<%= render tweet %>`.

   Now `app/views/tweets/index.html.erb` should look like:

   ```html
   <h1 class="mb-4">Tweets</h1>

   <section class="tweets">
     <% @tweets.each do |tweet| %>
       <%= render tweet %>
     <% end %>
   </section>

   <%= paginate @tweets, window: 1, outer_window: 1, theme: 'twitter-bootstrap-4' %>
   ```

   If we check what happens in the browser, we'll see that all still works like a charm.

   Finally, we can do a bit more _refactoring_ and leave `app/views/tweets/index.html.erb` like this:

   ```html
   <h1 class="mb-4">Tweets</h1>

   <section class="tweets">
     <%= render @tweets %>
   </section>

   <%= paginate @tweets, window: 1, outer_window: 1, theme: 'twitter-bootstrap-4' %>
   ```

   Now as we're done with the refactoring, we'll _intoduce_ the following small change to `app/views/tweets/_tweet.html.erb`:

   ```html
     ...
     <div class="card-body d-flex">
       <div class="avatar-holder rounded-circle border align-self-baseline mr-4">
         <%= image_tag tweet.user.avatar.url(:thumb), alt: "#{tweet.user.name} image" %>
       </div>
       ...
     </div>
   ```

   Then **_we need to change_** (fix) the _paperclip attachment **fallback image path**_ in `app/models/user.rb`:
   ```ruby
     has_attached_file :avatar,
                       styles: { medium: "300x300#", thumb: "100x100#" },
                       default_url: ":style/missing.png"
   ```

   Lastly, as a _final touch_ we may add the `romote: true` option to the `pagination` helper in `app/views/tweets/index.html.erb`, which will make a _smooth_ switching between the pages.
   The change will look like this:

   ```erb
   <%= paginate @tweets,
                window: 1,
                outer_window: 1,
                theme: 'twitter-bootstrap-4',
                remote: true %>
   ```

   And that's _all_ we need. Now our **home** page (**tweets index**) is _complete_.

   [back to top](a-simple-tweeting-app)

#### Users#show

- We'll start with **adding** some **general styles** to the app.

   In order to do so, we'll **add** the following **SCSS** to our `app/assets/stylesheets/application.scss`:

   ```scss
   html, body, #main-container {
     height: 100%;
   }

   #main-container {
     display: flex;
     flex-direction: column;

     footer {
       justify-self: flex-end;
     }
   }
   ```

   And we'll shange a bit the `app/views/layouts/application.html.erb`:

   ```html
   ...
   <body>
     <div class="container pt-5" id="main-container">
       <main>
         <% flash.each do |name, msg| %>
            <%= content_tag(:div, msg, class: "alert alert-#{name == 'notice' ? 'info' : 'danger'}") %>
         <% end %>

         <%= yield %>
      </main>

      <footer class="footer mt-auto">
        <hr>
        <p>© The Tweet Monsters 2017</p>
      </footer>
    </div>
   </body>
   ...
   ```

   Now, let's get our hands on the **users views**.

   We'll start from the **show** view. Just _paste_ inside the following code:

   ```html
   <div class="d-lg-flex mt-3">
     <section class="left mr-lg-5 mb-5">
       <h1 class="mb-3"><%= @user.name %>'s Profile</h1>

       <div class="card border-primary user my-3">
         <%= image_tag @user.avatar.url(:medium), class: "card-image-top rounded-circle bg-light" %>
         <div class="card-header bg-info text-white">
           <%= @user.name %>
         </div>
         <div class="card-body">
           <ul>
             <li class="my-2"><strong>Total tweets:</strong> <%= @user.tweets.count %></li>
             <li class="my-2"><strong>Total in the last week:</strong> <%= @user.tweets.where('created_at > ?', 1.week.ago).count %></li>
             <li class="my-2"><strong>Email:</strong> <%= @user.email %></li>
           </ul>

         </div>
           <% if @user == current_user %>
             <div class="btn-group d-flex">
               <%= link_to 'Edit', edit_user_path(@user), class: 'btn btn-info col-sm-6' %>
               <%= link_to 'Back', users_path, class: 'btn btn-secondary col-sm-6 ml-0' %>
             </div>
           <% else %>
             <%= link_to 'Back', users_path, class: 'btn btn-secondary btn-block' %>
           <% end %>
       </div>
     </section>

     <section class="right">
       <h2 class="mb-5"><%= @user.name %>'s tweets</h2>

       <%= render @user.tweets %>
     </section>
   </div>
   ```

   And here's _a minimalistic_ CSS touch in `app/assets/stylesheets/users.scss`:

   ```scss
   .user.card .card-image-top {
     max-width: 300px;
     margin: 1em auto;
   }

   @media only screen and (min-width: map-get($grid-breakpoints, sm)) {
     .user.card {
       width: 300px;

       .card-image-top {
         margin: 0;
       }
     }
   }
   ```

   With _those two changes_ we're creating a _nice and responsive_ look for the **user's show** page

   _Finally_, to make it even nicer, we can add **pagination** for the **tweets**, like this:

   Change the **show** method in `UsersController`:

   ```ruby
   ...
   def show
     @tweets = @user.tweets.page(params[:page]).per(10)
   end
   ...
   ```

   And then in `app/views/users/show.html.erb` just replace all `@user.tweets` with `@tweets` and call the _pagination helper_:

   ```erb
   <section class="right">
     <h2 class="mb-5"><%= @user.name %>'s tweets</h2>

     <%= render @tweets %>

     <%= paginate @tweets, theme: 'twitter-bootstrap-4' %>
   </section>
   ```

   .. and **we're done**! :)

   [back to top](a-simple-tweeting-app)

