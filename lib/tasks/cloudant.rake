desc "Cloudant export"
task "cloudant:export" => :environment do
  puts RestClient.post("#{CLOUDANT_URL}/activities/_bulk_docs", {:docs => Activity.all.collect(&:to_json)}.to_json, :content_type => :json, :accept => :json)
end

desc "Test Cloudant via Get"
task "cloudant:test" => :environment do
  puts RestClient.get("#{CLOUDANT_URL}/")
end
