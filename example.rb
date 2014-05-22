require_relative 'iflyer'

iflyer = IFLYER.new("~YOURAPIKEY~", "~YOURAPISECRET~", "1.6")

response = iflyer.request("events?limit=1")

print "Response: %{code} %{message} \n" % { :code => response.code, :message => response.message }
print "Body: "
print response.body
