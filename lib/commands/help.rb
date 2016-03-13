require_relative 'command'

class Help < Command
    def respond
        mynick = @client.config['xmpp']['botname']
        send("You can talk to me using commands, or speaking to me directly with #{mynick}")
        send("You can also PM me. If you PM me, you can specify the room you want to execute any " +
             "commands in by prefixing: `room ROOMNAME;` to the message. Example:")
        send("/code room #dev; remind @johnboy to take out the garbage in 5 minutes")
        send('Here is a list of things I can do...')
        send("/code " +
             "/joke - I can tell you a joke.\n" +
             "/learn joke TEXT... - Have me learn a joke to tell later.\n" +
             "/remind (me|@user) to ___ in ___ - Set a reminder for yourself or a user.\n" +
             "/build BUILDKEY - Start a build for BUILDKEY or ALIAS\n" +
             "/alias ALIAS BUILDKEY - Set a short alias for a specific BUILDKEY\n" +
             "/watch BUILDKEY - Watch a build and report.\n" +
             "/deploy BUILDKEY - Deploy a build.\n" +
             "/meme - Display a Meme. Use `/meme help` for more information.")

        send("Here is an example:")
        send("/code #{mynick} remind @bob to take the garbage out in 10 minutes")
        send("Keep in mind, you can also just use:")
        send("/code /remind @bob to take the garbage out in 10 minutes")
        send("Here are some more examples:")
        send("/code #{mynick} alias build MyBuild BLD-2772-PLD\n" +
             "/meme take my money\n" +
             "/remind me to brush my teeth on January 12 2020")
    end
end

