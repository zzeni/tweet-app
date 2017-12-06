# A Simple Tweeting App

## Task

Make a web application with **Ruby on Rails** that functions similarly to [Tweeter](https://twitter.com)

## Creation Instructions

### Initialization
```
rails new tweeter -T
cd tweeter
git commit -m"Initial commit"
```

### Models

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

1. **Associations**

   Add the following associations to the **User** & **Tweet** models:

   ```
   class User < ApplicationRecord
     has_many :tweets, dependent: :destroy
   end

   class Tweet < ApplicationRecord
     belongs_to :user
     end
   ```

1. **Attached image**

   Add the **Paperclip** stuff to the **User**:

   ```
   has_attached_file :avatar,
                     styles: { medium: "300x300#", thumb: "100x100#" },
                     default_url: "/images/:style/missing.png"
   ```

   Add the two **missing.png** images in the corresponding folders.

### Routes

Configure the routing (in `config/router.rb`)

```
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

### Views

Open your app's initial page (http://localhost:3056/). You'll get errors, because we've limited the routes for the tweets.

1. **Paths**

   Edit `app/views/tweets/index.html.erb`:

   ```
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

1. **Data**

   Let's generate some fake data, using **Fabrication** and **database seeds**.

   ```
   rails g fabrication:model user
   rails g fabrication:model tweet
   ```

   Edit the two generated files:

   ```
   # spec/fabricators/user_fabricator.rb
   Fabricator(:user) do
     name { Faker::LordOfTheRings.unique.character }
     email { Faker::Internet.unique.email }
     password "123456"
   end
   ```

   ```
   # spec/fabricators/tweet_fabricator.rb
     Fabricator(:tweet) do
     body { Faker::Lorem.paragraph(3) }
   end
   ```

   In `db/seeds.rb` put this:

   ```
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

1. **Design & Layout**

   Now it's time to fix the design.

   Start by deleting _all the content_ in `app/assets/stylesheets/scaffolds.scss` and leave the file _empty_.

   Replace the content of `app/views/tweets/index.html.erb` with the following:

   ```
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
   ```
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

   ```
   def index
     @tweets = Tweet.eager_load(:user).all
   end
   ```

   This will load all **users** data in the result and will prevent additional DB requests later.

   Now it's time to check what we've acheived and **refresh** the website.

1. **Paging**

   Add the [kaminari](https://github.com/kaminari/kaminari) and [bootstrap4-kaminari-views](https://github.com/KamilDzierbicki/bootstrap4-kaminari-views) gems to your **Gemfile**.

   Install them with `bundle install` and make the following changes in `tweets`:

   1. Change the `index` action in `TweetsController`:

      ```
      def index
        @tweets = Tweet.eager_load(:user).page(params[:page]).per(3)
      end
      ```

    1. And add the following line at the end of `app/views/tweets/index.html.erb`:

       ```
       <%= paginate @tweets, window: 1, outer_window: 1, theme: 'twitter-bootstrap-4' %>
       ```

1. **Display the tweet's user**

   Create a new file `app/views/tweets/_tweet.html.erb` and put inside the _html_ for the **tweet**, that we used in `app/views/tweets/index.html.erb`:

   ```
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

   ```
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

   ```
   <h1 class="mb-4">Tweets</h1>

   <section class="tweets">
     <%= render @tweets %>
   </section>

   <%= paginate @tweets, window: 1, outer_window: 1, theme: 'twitter-bootstrap-4' %>
   ```



