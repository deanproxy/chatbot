require 'command'

class Help < Command
    def respond(client, room, time=nil, nick=nil, text=nil)
        client.send(room, 'Here is a list of things I can do...')
        client.send(room, "/code * alias build _name_ _buildkey_\n" + 
            "* get build status for _buildkey_\n" +
            "* start build for _buildkey_\n" +
            "* watch build for _buildID_\n" +
            "* tell me a joke\n" +
            "* die (do you really want to hurt me?).")
    end
end

