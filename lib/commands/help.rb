require_relative 'command'

class Help < Command
    def respond(client, room, time=nil, nick=nil, text=nil)
        mynick = client.config['xmpp']['botname']
	client.send(room, "You can talk to me using commands, or speaking to me directly with #{mynick}")
        client.send(room, 'Here is a list of things I can do...')
	client.send(room, "/code " +
                "/joke - I can tell you a joke.\n" +
                "/remind (me|@user) to ___ in ___ - Set a reminder for yourself or a user.\n" +
                "/build BUILDKEY - Start a build for BUILDKEY or ALIAS\n" +
                "/alias ALIAS BUILDKEY - Set a short alias for a specific BUILDKEY\n" +
                "/watch BUILDKEY - Watch a build and report.\n" +
                "/deploy BUILDKEY - Deploy a build.\n" +
                "/meme - Display a Meme. Use `/meme help` for more information.")

        client.send(room, "Here is an example:")
        client.send(room, "/code #{mynick} remind @bob to take the garbage out in 10 minutes")
        client.send(room, "Keep in mind, you can also just use:")
        client.send(room, "/code /remind @bob to take the garbage out in 10 minutes")
        client.send(room, "Here are some more examples:")
        client.send(room, "/code #{mynick} alias build MyBuild BLD-2772-PLD\n" +
                    "/meme take my money\n" +
                    "/remind me to brush my teeth on January 12 2020")
    end
end

