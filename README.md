# Richmond

Richmond is a solution for culling documentation from files in a repo.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'richmond'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install richmond

## Usage

    Richmond.generate dir

This command will cause Richmond to scan all files in dir, recursively.
The tool looks for ruby comment blocks in the following format:

    =begin output-file: <output file name>
      some text
    =end

Successive blocks targeting the same output file can be written as follows:

    =begin append
      some more text
    =end

Richmond will take any text in the block and insert it into the specified output file.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/richmond/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
