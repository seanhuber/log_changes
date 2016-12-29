# LogChanges

`log_changes` is a simple gem that writes `ActiveRecord#changes` contents to model-dedicated logfiles.

## Usage
To log attribute changes for a model simply add `include LogChanges::Base` to an `ActiveRecord` model:

```ruby
class User < ApplicationRecord
  include LogChanges::Base

  def to_s
    "#{first_name} #{last_name}"
  end
end
```

In this example, if the `User` record with id = 1 had his name updated you may see an entry like this appear `logs/record_changes/2016.12_User.log`:

```
12/29/2016 at 3:48 PM (UTC)
Updated User {id: 1} John Smith
  first_name:
    FROM: Johnny
    TO: John
  last_name:
    FROM: Smithers
    TO: Smith
```

Logfiles are prefixed with a month stamp (to prevent them from getting too big over time).

### Aggregating logfiles

If your Rails app runs in a load-balanced distributed environment, you may wish to aggregate logs from multiple servers. `log_changes` comes with a rake task for this purpose:

```
rake log_changes:merge['/path/to/logs/directory']
```

Make sure the path you pass to the task has multiple subfolders (one per server), each with a `record_changes` directory containing the log files.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'log_changes'
```

And then execute:
```bash
$ bundle install
```

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
