require "pry"
require "resolv"
require "http"
require 'json'

class DomainConnect
  def initialize(domain)
    @domain = domain
    @_domainconnect, @cname = discovery()
    settings.each { |iv, val| instance_variable_set("@#{iv}", val) } 
    # sets urlSyncUX, urlAsyncUX, urlControlPanel, providerName and urlAPI and any other properties returned
    @providerId = "exampleservice.domainconnect.org"
    @serviceId = "template1"
  end
  
  def discovery()
    Resolv::DNS.open do |dns|
      txt = dns.getresources "_domainconnect.#{@domain}", Resolv::DNS::Resource::IN::TXT
      cname = dns.getresources "_domainconnect.#{@domain}", Resolv::DNS::Resource::IN::CNAME
      return txt.first.data, cname.first.name.to_s
    end
  end

  def settings()
    JSON.parse(HTTP.get("https://#{@_domainconnect}/v2/#{@domain}/settings").body)
  end

  # Sync flow. 
  # FIXME we are blocked on not having a serviceID
  # FIXME the godaddy response does not contain providerID
  def template()
    HTTP.get("#{@urlAPI}/v2/domainTemplates/providers/#{@providerId}/services/#{@serviceId}")
  end
  
  # ASync flow to get any further in testing with GoDaddy we need to get an oauth application up
  def async()
    HTTP.get("#{@urlAsyncUX}/v2/domainTemplates/providers/#{@providerId}")
  end
end

dc = DomainConnect.new("platformsh.cloud")

puts dc.async
puts dc.template
