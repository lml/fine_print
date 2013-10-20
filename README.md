# FinePrint

FinePrint is a Rails gem (engine) that makes managing web site agreements (terms, privacy policy, etc) simple and easy.

## Installation

Add this line to your application's Gemfile:

```rb
gem 'fine_print'
```

And then execute:

```sh
$ bundle
```

Or install it yourself:

```sh
$ gem install fine_print
```

Then execute the following command to copy the necessary migration and the initializer to your application:

```sh
$ rake fine_print:install
```

And then migrate your database:

```sh
$ rake db:migrate
```

Also add FinePrint to your application's routes:

```rb
mount FinePrint::Engine => "/fine_print"
```

And provide a link on your site for administrators to access the FinePrint engine to manage agreements.

```erb
<%= link_to 'FinePrint', fine_print_path %>
```

## Configuration

After installation, the initializer for FinePrint will be located under `config/initializers/fine_print.rb`.
Make sure to configure it to suit your needs.
Pay particular attention to `user_admin_proc`, as you will be unable to manage your agreements unless you set up this proc to return true for your admins.

## Usage

FinePrint adds a new method to all controllers that behaves like a before_filter.
It can be accessed by calling `fine_print_agreement` from any controller.
This method takes an agreement name and an options hash.
Accepted options are (see initializer for more explanation):

- `only` and `except` just like a before_filter

- `agreement_notice` notice to be shown to the user above the agreement

- `accept_path` path to redirect users to when an agreement is accepted and no referer information is available
- `cancel_path` path to redirect users to when an agreement is not accepted and no referer information is available
- `use_referers` false if you want users to always be redirected to the above paths

- `use_modal_dialogs` true if you want to use FinePrint's modal dialogs

Example:

```rb
fine_print_agreement 'terms of use', :except => :index, :use_modal_dialogs => true
```

This gem also adds the `fine_print_dialog` helper method, which needs to be called (usually from your layout) if you want to use FinePrint's modal dialogs.
This method only takes an options hash. Accepted options are:

- `width`
- `height`

Example:

```erb
<%= fine_print_dialog, :width => 800, :height => 600 %>
```

## Managing Agreements

Here are some important notes about managing your agreements with FinePrint:

- Agreements are referred to on your controller by the name you specified
- Creating another agreement with the same name will make it a new version of a previous agreement
- Agreements need to be marked as `ready` to be able to be accepted by users
- The latest version of each agreement that is marked as `ready` will always be used
- Agreements cannot be modified after at least one user has accepted them, but you can always create new versions
- When a new version is present, users will be asked to accept it the next time they visit a controller action that calls `fine_print_agreement`

## Customization

You can customize FinePrint's stylesheets, javascripts, views and even controllers to suit your needs.

Run the following command to copy a part of FinePrint into your main application:

```sh
$ rake fine_print:copy:folder
```

Where folder is one of `stylesheets`, `javascripts`, `layouts`, `views` or `controllers`.

Example:

```sh
$ rake fine_print:copy:views
```

Alternatively, you can run the following command to copy all of the above into your main application:

```sh
$ rake fine_print:copy
```

## Testing

Run `bundle exec rake db:migrate` then `bundle exec rake app:db:test:prepare`.  Then call the specs.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Create specs for your feature
4. Ensure that all specs pass
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create new pull request
