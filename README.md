# FinePrint

[![Gem Version](https://badge.fury.io/rb/fine_print.svg)](http://badge.fury.io/rb/fine_print)
[![Build Status](https://travis-ci.org/lml/fine_print.svg?branch=master)](https://travis-ci.org/lml/fine_print)
[![Code Climate](https://codeclimate.com/github/lml/fine_print/badges/gpa.svg)](https://codeclimate.com/github/lml/fine_print)

FinePrint is a Rails engine in gem form that makes managing web site agreements
(terms of use, privacy policy, etc) simple and easy.

As the meaning of 'agreement' can be somewhat ambiguous (meaning either the
thing someone agrees to or the record of the agreement between that thing and
the user), we call a set of terms a 'contract' and a user's agreement to that
contract a 'signature'.

A version history of all contracts is maintained. Once a particular version of
a contract is published, it becomes available for users to sign. Once it has
been signed, it cannot be changed. To effect a change, a new version must be
created and published. When a new version of a contract is created and
published, users visiting pages requiring signature of that contract will be
redirected to a page where they can sign the new contract.

FinePrint provides views for admins to manage contracts and signatures and for
users to sign those contracts, although these views can be overriden by
application-specific views. FinePrint also provides convenience methods for
finding unsigned contracts and for recording when a user signs a contract.

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

And provide a link on your site for administrators to access the FinePrint engine to manage your contracts.

```erb
<%= link_to 'FinePrint', fine_print_path %>
```

## Configuration

After installation, the initializer for FinePrint will be located under
`config/initializers/fine_print.rb`. Make sure to configure it to suit
your needs. Pay particular attention to `authenticate_manager_proc`,
as you will be unable to manage your contracts unless you setup
this proc to return `true` for your admins.

## Usage

You can choose to check if users signed contracts either
as a before_filter or inside your controller actions.

### Option 1 - As a before_filter

If you choose to have FinePrint work like a before_filter, you can user the following class methods, which are automatically added to your controllers:

```rb
fine_print_require(contract_names..., options_hash)
fine_print_skip(contract_names..., options_hash)
```

- `fine_print_require` will redirect users to a page that asks them
  to sign each contract provided, in order
- `fine_print_skip` is used to skip asking the user to sign
  the given contracts for certain controller actions

These methods take a list of contract names to check, along with an options hash.
If no contract names are provided, or if :all is passed to one of the methods,
ALL existing contracts will be required or skipped.

The options hash can include any options you could pass to a `before_filter`,
e.g. `only` and `except`, plus the FinePrint-specific option
`redirect_to_contracts_proc`, which is a proc that controls
where users are redirected to in order to sign contracts.

Example:

```rb
class MyController < ApplicationController
  fine_print_require :terms_of_use, :privacy_policy, except: :index
end
```

Before checking the contracts to be signed, FinePrint will check that the user
is logged in by calling the authenticate_user_proc. This method should render
or redirect the user if they are not signed in.

One way you can use these methods is to require signatures in every controller
by default, and then to skip them in certain situations, e.g.:

```rb
class ApplicationController < ActionController::Base
  fine_print_require :terms_of_use
end
```

```rb
class NoSigsRequiredController < ApplicationController
  fine_print_skip :terms_of_use
end
```

### Option 2 - Inside your controller actions

If, instead, you have to check a contract signature inside a controller action,
you can use the following instance methods, also available in all controllers:

```rb
fine_print_require(contract_names..., options_hash)
fine_print_return
```

- `fine_print_require` works just like the before_filter version and will
  redirect the user if they haven't signed one or more of the given contracts
- `fine_print_return` can be used to return from a redirect
  made by `fine_print_require`

### Displaying and signing contracts

When a set of contracts is found by FinePrint to be required but unsigned,
and the user is allowed to sign contracts, FinePrint will call the
redirect_to_contracts_proc, which should redirect the user to some action
that allows the user to sign said contracts, passing along the id's of the
contract objects that need to be signed. By default, it redirects to one
of FinePrint's views that presents one contract at a time to the user.

If you choose to create this view yourself, your job as the site developer is
to present the terms to the user and ask them to sign them. This normally
involves the user clicking an "I have read the above terms" checkbox which
enables an "I Agree" button. When the "Agree" button is clicked (and you should
verify that the checkbox is actually clicked in the params passed to the
server), you need to send the information off to a controller method that will
mark the contract as signed using the `FinePrint.sign_contract` method. The
following methods in the FinePrint module can be used to help you find contract
objects and mark them as signed:

```rb
FinePrint.get_contract(contract_object_or_id_or_name)
FinePrint.sign_contract(user, contract_object_or_id_or_name)
FinePrint.signed_contract?(user, contract_object_or_id_or_name)
FinePrint.signed_any_version_of_contract?(user, contract_object_or_id_or_name)
```

If you require more explanation about these methods and their arguments, check the `lib/fine_print.rb` file.

### Redirecting users back

Regardless if you use the class before_filter or instance methods,
after your contract is signed you can use the `fine_print_return` controller
instance method to send the user back to the place where they came from.

If there are multiple unsigned contracts, you are not required to ask the user
to sign them all at once. One strategy is to present only the first unsigned
contract to them. Once they sign it, they'll be redirected to where they were
trying to go and FinePrint will once again determine that they still have
remaining unsigned contracts, and redirect them back to your contract signing
path with one less contract id passed in.

## Managing Contracts

Here are some important notes about managing your contracts with FinePrint:

- Contracts have a name and a title; the former is used by your code,
  the latter is intended for display to end users and site admins.
- Creating another contract with the same name as an existing contract
  will make it a new version of that existing contract.
- Contracts need to be explicitly published to be available to users to sign
  (this can be done on the contracts admin page).
- The latest published version is what users will see.
- A contract cannot be modified after at least one user has signed it,
  but you can always create a new version.
- When a published contract version is available but has not been signed,
  users will be asked to accept it the next time they visit a controller action
  that calls either `fine_print_require` with that contract's name.

## Customization

You can customize FinePrint's stylesheets, javascripts, views
and even controllers to suit your needs.

Run the following command to copy a part of FinePrint
into your main application:

```sh
$ rake fine_print:copy:folder
```

Where folder is one of `stylesheets`, `layouts`, `views` or `controllers`.

Example:

```sh
$ rake fine_print:copy:views
```

Alternatively, you can run the following command
to copy all of the above into your main application:

```sh
$ rake fine_print:copy
```

## Testing

From the gem's main folder, run `bundle install`,
`bundle exec rake db:migrate` and then
`bundle exec rake` to run all the specs.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Create specs for your feature
4. Ensure that all specs pass
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create new pull request
