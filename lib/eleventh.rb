require 'aws-sdk'
require 'json'
require 'zip'
require 'fileutils'
require 'base64'
require 'open-uri'

module Eleventh
  VERSION = '0.0.0'

  def self.init_project(initPath, region, profile_name)

    unless File.exists?(initPath)
      FileUtils.mkdir_p initPath
      FileUtils.mkdir_p "#{initPath}/builds"

      config = {
        'AWS' => {
          'Region' => region,
          'CredentialsProfile' => profile_name
        }
      }

      File.open("#{initPath}/eleventh.json", "w+") { |file| file.write(JSON.pretty_generate config, :indent => '  ') }

      lambda = Aws::Lambda::Client.new(
        region: region,
        credentials: Aws::SharedCredentials.new(:profile_name => profile_name)
      )

      lambda.list_functions.functions.each do |function|
        self.init_function(initPath, lambda, function)
      end

      {:success => true}
    else
      {:success => false, :message => "Argh! Can't initialize the project there because something already exists." }
    end
  end

  def self.init_function(initPath, lambda, function)
    function_name = function.function_name

    FileUtils.mkdir_p "#{initPath}/functions/#{function_name}"

    config = {
      "FunctionName" => function_name,
      "MemorySize" => function.memory_size,
      "Handler" => function.handler,
      "Role" => function.role,
      "Timeout" => function.timeout,
      "Runtime" => function.runtime,
      "Description" => function.description
    }

    File.open("#{initPath}/functions/#{function_name}/lambda.json", "w+") { |file| file.write(JSON.pretty_generate config, :indent => '  ') }

    File.open("#{initPath}/builds/#{function.function_name}.zip", "wb") do |saved_file|
      function_code = lambda.get_function(:function_name => function.function_name).code

      open(function_code.location, "rb") do |read_file|
        saved_file.write(read_file.read)
      end
    end

    Zip::File.open("#{initPath}/builds/#{function_name}.zip") do |zip_file|
      zip_file.each do |entry|
        entry.extract("#{initPath}/functions/#{function_name}/#{entry.name}")
      end
    end
  end

  def self.sync
    if File.exists?('./eleventh.json')
      config = JSON.parse(File.read('./eleventh.json'))

      lambda = Aws::Lambda::Client.new(
        region: config['AWS']['Region'],
        credentials: Aws::SharedCredentials.new(:profile_name => config['AWS']['CredentialsProfile'])
      )

      begin
        function_names = lambda.list_functions.functions.map{|f| f.function_name}

        # Remove old builds
        Dir.foreach('./builds') do |f|
          if ['.', '..'].include? f then next
          elsif File.directory?("./builds/#{f}") then FileUtils.rm_rf("./builds/#{f}")
          else FileUtils.rm("./builds/#{f}")
          end
        end

        local_functions = []

        Dir.foreach('./functions') do |f|
          if ['.', '..'].include? f then next
          else local_functions << f
          end
        end

        local_functions.each do |function_name|
          if File.exists?("./functions/#{function_name}/lambda.json")
            function_config = JSON.parse(File.read("./functions/#{function_name}/lambda.json"))

            Zip::File.open("./builds/#{function_name}.zip", Zip::File::CREATE) do |zipfile|
              zipfile.add('index.js', "./functions/#{function_name}/index.js")
            end

            if function_names.include? function_name
              resp = lambda.update_function_configuration({
                function_name: function_name,
                role: function_config['Role'],
                handler: function_config['Handler'],
                description: function_config['Description'],
                timeout: function_config['Timeout'],
                memory_size: function_config['MemorySize']
              })

              resp = lambda.update_function_code({
                function_name: function_name,
                zip_file: File.read("./builds/#{function_name}.zip")
              })
            else
              resp = lambda.create_function({
                function_name: function_name,
                runtime: function_config['Runtime'],
                role: function_config['Role'],
                handler: function_config['Handler'],
                description: function_config['Description'],
                timeout: function_config['Timeout'],
                memory_size: function_config['MemorySize'],
                code: {
                  zip_file: File.read("./builds/#{function_name}.zip")
                },
              })
            end

            puts "Synced #{function_name} (#{resp.function_arn})"
          end
        end

        {:success => true}
      rescue Aws::Lambda::Errors::ServiceError => e
        puts e.message
        {:success => false, :message => "Oh no! Something went wrong."}
      end
    else
      {:success => false, :message => "Darn! No eleventh.json config file."}
    end
  end
end
