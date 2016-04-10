require 'openssl'
require 'open-uri'

def encodeURIComponent(val)
  URI.escape(val, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
end

def urlbox(url, options={}, format='png')
  urlbox_apikey = Rails.application.secrets.urlbox_api_key
  urlbox_secret = Rails.application.secrets.urlbox_secret

  query = {
    :url         => url, # required - the url you want to screenshot
    :force       => options[:force], # optional - boolean - whether you want to generate a new screenshot rather than receive a previously cached one - this also overwrites the previously cached image
    :full_page   => options[:full_page], # optional - boolean - return a screenshot of the full screen
    :thumb_width => options[:thumb_width], # optional - number - thumbnail the resulting screenshot using this width in pixels
    :width       => options[:width], # optional - number - set viewport width to use (in pixels)
    :height      => options[:height], # optional - number - set viewport height to use (in pixels)
    :quality     => options[:quality], # optional - number (0-100) - set quality of the screenshot
    :delay       => options[:delay], # optional - number (0-100) - set quality of the screenshot
    :renderer    => 'beta'
  }

  query_string = query.
    sort_by {|s| s[0].to_s }.
    select {|s| s[1] }.
    map {|s| s.map {|v| encodeURIComponent(v.to_s) }.join('=') }.
    join('&')

  token = OpenSSL::HMAC.hexdigest('sha1', urlbox_secret, query_string)

  "https://api.urlbox.io/v1/#{urlbox_apikey}/#{token}/#{format}?#{query_string}"
end

class Screenshot
  def initialize(url)
    @url = urlbox(url, {full_page: true, quality: 90, force: true}, 'jpg')
  end

  def url
    @url
  end
end
