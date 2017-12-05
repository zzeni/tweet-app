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

