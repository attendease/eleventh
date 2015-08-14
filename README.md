# Eleventh: Lambda Function Synchronization

This gem will synchronize Amazon Web Services Lambda functions locally for your development ease. This will allow you to easily edit the functions and configuration, write tests for your functions or add them to version control.

## Preparation

Log in to your AWS account and do the following:

- [IAM] Create a new user to access your Lambda functions. I called my user `eleventh`. Take note of the `Access Key ID` and `Secret Access Key`.
- [IAM] Go to your new user and click the `Attach Policy` button. Choose the `AWSLambdaFullAccess` policy and attach it.

## Installation

    gem install eleventh

You will also need to setup and configure the AWS CLI if you haven't done so. This utility will make use of your stored credentials.

    aws configure

If you have already configured the AWS CLI you can also set up a new profile for your Lambda management.

    aws configure --profile eleventh

More information here: http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html

## Usage

### Project initialization

Create a project and sync your Lambda functions

    eleventh init <project_name>

By default it will use the `us-west-2` region and `default` profile_name. If you require a different region use the `--region` option. If you require a different profile_name use the `--profile_name` option.

    eleventh init <project_name> --region us-west-2 --profile_name eleventh

### Project synchonization

To sync all local changes to AWS Lambda

    cd project_name

    eleventh sync

## Project Structure

```
project_name
  |
  |--- eleventh.json (eleventh configuration file)
  |
  |--- builds (zip archives of your code)
  |
  |--- functions
         |
         |--- <FunctionName>
                |
                |--- index.js (your function code)
                |--- lambda.json (your function configuration)
```

## Eleventh?

Lambda (λ) is the 11th letter of the Greek alphabet.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Copyright (C) 2015 Attendease (https://attendease.com/)

The MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
