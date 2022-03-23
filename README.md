# Authorizer

I wrote it in Ruby as that is most recently what is familiar to me. One thing at least initially I was going for was [a functional core and imperative shell](https://www.destroyallsoftware.com/screencasts/catalog/functional-core-imperative-shell), trying to keep all of the mutable state to the outside of the program. I don't think I stuck to that entirely but I think it's a good aspect of functional-style programming even when using non-functional languages. 

I do believe that one should avoid instantiating dependencies directly if possible and injecting them instead, so I did pass in the database, input streams, and output streams, or at least simple examples of them, to establish an interface and abstract away the implementation details (a hash for example, for the data store).

I tried for the most part to isolate business logic to the Authorizer, using the RuleEngine to encapsulate some of those rule violations.

I only wrote BDD-style tests for the main business logic, the Authorizer class. The rest is primarily boilerplate or simple getters/setters for example, and I don't believe that needs to be tested generally (aside from possibly an acceptance/smoke test). I would concede that possibly on mission-critical financial systems you might want to cover more of the boundary cases for the rules etc. In general, I consider code coverage to not be a sufficient metric (other than as a negative signal if you have no coverage), and really one needs to consider test quality.

## Installation

This assumes a somewhat modern version of Ruby on a Mac/Linux machine as well as Bundler installed. 

```bash
$ ruby -v
ruby 2.7.0p0 (2019-12-25 revision 647ee6f091) [x86_64-darwin19]
$ gem install bundler
```

## Usage

```
$ ruby authorizer.rb < input.txt
{:activeCard=>true, :availableLimit=>100, :violations=>[]}
{:activeCard=>true, :availableLimit=>80, :violations=>[]}
{:activeCard=>true, :availableLimit=>80, :violations=>["insufficient-limit"]}
```

## Test

```
$ bundle install
$ rspec spec/authorizer_spec.rb
.......

Finished in 0.00443 seconds (files took 0.09623 seconds to load)
7 examples, 0 failures
```