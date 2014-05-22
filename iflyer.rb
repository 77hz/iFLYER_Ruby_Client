require "net/http"
require "uri"
require "digest"
require "yaml"

class IFLYER
  @base_url
  @version
  @key
  @secret
  
  def initialize(key, secret, version = nil)
    @base_url = "https://api.iflyer.tv"
    @version = "1.6"
    @key = key
    @secret = secret
    
    if version != nil
      @version = version
    end
  end

  ## Function to convert a given integer string/number into hexa decimal string
  def _dec2hex(number)
     number = Integer(number);
     hex_digit = "0123456789abcdef".split(//);
     ret_hex = '';
     while(number != 0)
        ret_hex = String(hex_digit[number % 16 ] ) + ret_hex;
        number = number / 16;
     end
     return ret_hex; ## Returning HEX
  end
  
  def sign(request, url, key, secret)
    timestamp = Time.now.to_i
    hexstamp = _dec2hex(timestamp)
    
    regexMatch = /^https?:\/\/(.+)$/.match(url)
    if regexMatch
      url = $1
    end
    
    vars = {
      :hexstamp => hexstamp,
      :secret => secret,
      :method => request.method,
      :url => url
    }
    signatureSubject = "SIGN:%{hexstamp}:%{secret}:%{method}%{url}" % vars
    
    if request.body
      signatureSubject = signatureSubject + request.body
    end
    
    hash = Digest::MD5.hexdigest(signatureSubject)
    randomCutOfHash = hash[3 + Random.rand(8), 20]
    sign = randomCutOfHash[0, 8] + hexstamp + randomCutOfHash[8..-1]
    
    return sign
  end
  
  def request(uri, method = 'GET', data = nil)
    abs_url = "%{url}/v%{version}/%{uri}" % { :url => @base_url, :version => @version, :uri => uri }
    url = URI.parse(abs_url);
    
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    if method == "GET"
      request = Net::HTTP::Get.new(url.request_uri)
    elsif method == "POST"
      request = Net::HTTP::Post.new(url.request_uri)
    end
    request["X-iFLYER-APIKey"] = @key;
    request["X-iFLYER-Sign"] = sign(request, abs_url, @key, @secret)
    
    response = http.request(request)
    
    return response
  end
  
end
