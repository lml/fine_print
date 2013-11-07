# FinePrint

FinePrint is a Rails gem (engine) that makes managing web site agreements (terms, privacy policy, etc) simple and easy.

As the meaning of 'agreement' can be somewhat ambiguous (meaning either the thing someone agrees to or the record of the agreement between that thing and the user), we call a set of terms a 'contract' and a user's agreement to that contract a 'signature'.

A version history of all contracts is maintained.  Once a particular version of a contract is published, it becomes available for users to sign.  Once a version has been signed, it cannot be changed (to effect a change, a new version must be created and published).  When a new version of a contract is created and published, users visiting pages requiring signature of that contract will be redirected to a page you specify where they can sign the new contract.

FinePrint provides views for admins to manage contracts and signatures, but does not provide views for the application to display contracts to end users, as that functionality is specific to each particular application.  FinePrint does provide convenience methods for finding unsigned contracts and for recording when a user signs a contract.

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

And provide a link on your site for administrators to access the FinePrint engine to manage contracts.

```erb
<%= link_to 'FinePrint', fine_print_path %>
```

## Configuration

After installation, the initializer for FinePrint will be located under `config/initializers/fine_print.rb`.
Make sure to configure it to suit your needs.
Pay particular attention to `user_admin_proc`, as you will be unable to manage your contracts unless you set up this proc to return true for your admins.

## Usage

To require that your users sign the most recent version of a contract, call 
`fine_print_get_signatures` in your controllers, just as you would a 
`before_filter` (in fact this method works by adding a `before_filter` for you).

This method takes a list of contract names (given either as strings or as 
symbols), along with an options hash.

The options hash can include any options you could pass to a `before_filter`, e.g. `only` and `except`.

Example:

```rb
class MyController < ApplicationController
  fine_print_get_signatures :terms_of_use, :privacy_policy,
                            :except => :index
```

You should only try to get signatures when you have a user who is logged in 
(FinePrint will raise an exception if you try to get a non-logged in user to sign
an agreement, as that does not make any sense).  This normally means that before
the call to `fine_print_get_signature` you should call whatever `before_filter` 
gets a user to login.

Just like how rails provides a `skip_before_filter` method to offset `before_filter` calls, 
FinePrint provides a `fine_print_skip_signatures` method.  This method takes the same 
arguments as, and can be called either before or after, `fine_print_get_signatures`.

One way you may want to use these methods is to require signatures in every controller 
by default, and then to skip them in certain situations, e.g.:

```rb
class ApplicationController < ActionController::Base
  fine_print_get_signatures :terms_of_use
```

```rb
class NoSigsRequiredController < ApplicationController
  fine_print_skip_signatures :terms_of_use
```

When a set of contracts is found by FinePrint to be required but unsigned, FinePrint redirects 
the user to the path specified by the `pose_contracts_path` configuration variable, with
the names of the unsigned contracts passed along in a `terms` array in the URL parameters.

Your job as the site developer is to present the terms to the user and ask them to sign them.
This normally involves the user clicking an "I have read the above terms" checkbox which enables an "I Agree" button.
When the "Agree" button is clicked (and you should verify that the checkbox is actually clicked in the params passed to the server), you need to send the information off to a controller 
method that can call `FinePrint.sign_contract` which takes a user and a contract name, ID, or
object.  On success this controller method can send the user back to where they were trying to
go by redirecting them to the path stored in the `:fine_print_return_to` session variable, e.g.:

```rb
redirect_to session.delete(:fine_print_return_to) || root_path 
```

If there are multiple unsigned contracts, you are not required to get the user to sign
them all in one page.  One strategy is to present only the first unsigned contract to them
for signature.  Once they sign it, they'll be redirected to where they were trying to 
go and FinePrint will see again that they still have remaining unsigned contracts, and
FinePrint will direct them back to your `pose_contracts_path` with one fewer contract
name passed in.

Note that are some utility methods available in the `FinePrint::Utilities` module.

## Managing Contracts

Here are some important notes about managing your contracts with FinePrint:

- Contracts have a name and a title; the former is used by your code, the latter 
is intended for display to end users.
- Creating another contract with the same name as an existing contract will make it a new version of that existing contract.
- Contracts need to be explicitly published to be available to users to sign (this can be done on the contracts admin page).
- The latest published version is what users will see.
- A contract cannot be modified after at least one user has signed it, but you can always create a new version.
- When a published contract version is available but has not been signed, users will be asked to accept it the next time they visit a controller action that calls `fine_print_get_signatures` for that contract's name.

## Customization

You can customize FinePrint's stylesheets, javascripts, views and even controllers to suit your needs.

Run the following command to copy a part of FinePrint into your main application:

```sh
$ rake fine_print:copy:folder
```

Where folder is one of `stylesheets`, `layouts`, `views` or `controllers`.

Example:

```sh
$ rake fine_print:copy:views
```

Alternatively, you can run the following command to copy all of the above into your main application:

```sh
$ rake fine_print:copy
```

## Testing

From the gem's main folder, run `bundle install`, `bundle exec rake db:migrate` and then `bundle exec rake` to run all the specs.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Create specs for your feature
4. Ensure that all specs pass
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create new pull request
