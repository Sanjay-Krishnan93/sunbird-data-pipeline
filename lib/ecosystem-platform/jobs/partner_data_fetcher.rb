require 'pry'
require 'hashie'
require 'elasticsearch'
require 'base64'
require 'zip'
require 'net/http'
require 'json'

require_relative '../utils/ep_logging.rb'

module EcosystemPlatform
  module Jobs
    class PartnerDataFetcher

      PROGNAME = 'partner_data_fetcher.jobs.ep'
      BASE_PATH = "/tmp/data_exhaust/"

      include EcosystemPlatform::Utils::EPLogging

      def self.perform(url,licensekey,from_date=nil,to_date=nil)
        logger.start_task
        logger.info("INITIALIZING CLIENT")
        wrapper = {
          id: "ekstep.data_exhaust_user",
          ver: "1.0",
          ts: Time.now.strftime('%Y-%m-%dT%H:%M:%S%z'),
          params: {
            requesterId: "",
            did: "",
            key: "",
            msgid: ""
          },
          request: {
            licenseKey: licensekey
          }
        }
        file_path = BASE_PATH + SecureRandom.uuid + ".gz"
        FileUtils.mkdir_p(BASE_PATH) unless Dir.exist?(BASE_PATH)
        logger.info("CREATING FILE PATH: #{file_path}")

        data_exhaust_api_url = construct_url(url,from_date,to_date)
        logger.info("CONSRUCTING DATA EXHAUST API URL: #{data_exhaust_api_url}")

        send_request(wrapper,data_exhaust_api_url,file_path)
        logger.info("EXTRACTING ZIP FILE")

        extract_data(file_path)
      end

      def self.send_request(data,url,file_path)
        uri = URI.parse(url)
        Net::HTTP.start(uri.host, uri.port) do |http|
          req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' => 'application/json'})
          if url.start_with? "https"
            http.use_ssl = true
          end
          req.basic_auth ENV["API_USER"], ENV["API_PASS"]
          req.body = JSON.generate(data)
          http.request req do |response|
            if response.code == '200'
              logger.info("API RESPONSE IS SUCCESS ")
              open file_path, 'w' do |io|
                response.read_body do |chunk|
                  io.write chunk
                end
              end
            else
              logger.info("ERROR RESPONSE: #{JSON.parse(response.body)}")
            end
          end
        end
      end

      def self.extract_data(file_path)
        if File.exist?(file_path)
          Zip::File.open(file_path) { |zip_file|
            zip_file.each { |f|
              f_path=File.join(BASE_PATH, f.name)
              FileUtils.mkdir_p(File.dirname(f_path))
              zip_file.extract(f, f_path) unless File.exist?(f_path)
            }
          }
        else
          logger.info("UNABLE TO FIND ZIP FILE : #{file_path}")
        end

        # FileUtils.rm(file_path)
      end

      def self.construct_url(url,from_date,to_date)
        if from_date && to_date
          url + "/" + from_date + "/" + to_date
        else
          url
        end
      end
    end
  end
end
