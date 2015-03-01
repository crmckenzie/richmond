# Richmond

Richmond is a solution for culling documentation from files in a repo.

## What's it for?

I was not happy with existing solutions for generating swagger documentation
from ruby code. For this reason I started hand-editing the swagger JSON files.
This became tedious over time, and I decided that editing the files in YAML
would be nicer. This solution worked well, but still required a lot of context-
switching between the YAML files and the api implementation. I wrote richmond
so that I could do this:

    =begin output-file: swagger.yaml
      api: /my/url/{param1}
        parameters
        - name: param1
      ... snipped for brevity
    =end
    get '/my/url/:param1' do
      param1 = params[:param1]
      ... snipped for brevity
    end

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

# Configuration

Richmond will look for a file called .richmond in the root directory you are running against.
If it finds the .richmond file, it will load it.

You can use the select or reject methods to change which files Richmond will include or exlude
in it's processing.

    # Richmond doesn't like binary files
    Richmond.reject do |file|
      file.match /images/
    end

    # I only want to parse .rb files
    Richmond.select do |file|
      file.match /\.rb$/
    end

## Contributing

1. Fork it ( https://github.com/crmckenzie/richmond/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
