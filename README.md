# Simple Tweeter App

## Creation Instructions

### Models

```
rails new tweeter -T
cd tweeter
git commit -m"Initial commit"
```

Add the following gems to **Gemfile**: `devise`, `paperclip`, `faker`, `fabrication`, `pry-rails`

```
bundle

rails g scaffold user name:string
rails g scaffold tweet body:string user:belongs_to

rails g devise:install
rails g devise user

rails g migration add_avatar_to_users
```

Edit all migration files.

Add index for the **name** column in `users` table.

Set to not null the **name** in `users` and the **body** in `tweets`.

Remove all unnecessary stuff from the **devise** migration. You will use only these **devise** modules: _database_authenticatable_, _registerable_, _recoverable_, _rememberable_, _trackable_, _validatable_

```
rails db:migrate
```

Add the following associations to the **User** & **Tweet** models:

```
class User < ApplicationRecord
  has_many :tweets, dependent: :destroy
end

class Tweet < ApplicationRecord
  belongs_to :user
end
```

Add the **Paperclip** stuff to the **User**:

```
has_attached_file :avatar,
                  styles: { medium: "300x300#", thumb: "100x100#" },
                  default_url: "/images/:style/missing.png"
```

Add the two **missing.png** images in the corresponding folders.

### Routes

Configure routing and start your server:

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

```
rails s -p 3056
```

### Views

Open your app's initial page (http://localhost:3056/). You'll get errors, because we've limited the routes for the tweets.

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

Let's generate some fake data, using **Fabrication** and **database seeds**.

```
rails g fabrication:model user
rails g fabrication:model tweet
```

Edit the two files:

```
Fabricator(:user) do
  name { Faker::LordOfTheRings.unique.character }
  email { Faker::Internet.unique.email }
  password "123456"
end

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


