class TwilioAgent
  SID = ENV['TWILIO_SID']
  TOKEN = ENV['TWILIO_TOKEN']
  DEFAULT_FROM = ENV['TWILIO_DEFAULT_FROM']

  class SMS
    def initialize(options)
      @options = {from: DEFAULT_FROM}.merge(options)
    end

    def deliver
      Client.new.account.sms.messages.create(@options)
    end
  end

  class Client
    attr_reader :client

    def initialize
      @client = Twilio::REST::Client.new(SID, TOKEN)
    end

    def account
      @account ||= client.account
    end
  end
end
