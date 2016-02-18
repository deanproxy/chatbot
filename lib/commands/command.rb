class Command
    attr_reader :params

    def initialize(params)
        @params = params
    end

    def respond(client, room, time=nil, nick=nil, text=nil)
        # Do stuff
    end
end
