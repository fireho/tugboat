require 'thor'

module Tugboat
  autoload :Middleware, "tugboat/middleware"

  class CLI < Thor
    include Thor::Actions

    desc "help [command]", "Describe commands or a specific command"
    def help
      super
      say "To learn more or contribute to tugboat, please see github.com/pearkes/tugboat"
    end

    desc "authorize", "Authorize a DigitalOcean account with tugboat"
    def authorize
      Middleware.sequence_authorize.call({})
    end

    desc "list", "Retrieve a list of your droplets"
    def list
      Middleware.sequence_list_droplets.call({})
    end

    desc "ssh", "SSH into a droplet"
    def ssh
      say "Found droplet: 'pearkes-admin-001'", :green
      say "Executing SSH..."
    end

    desc "create", "Create a droplet"
    def create
      droplet_name = ask "Enter name of droplet:"
      say "Creating '#{droplet_name}' (region: 1, size: 64, image ID: 2676)...", :yellow
      say "Succesfully created '#{droplet_name}'", :green
    end

    desc "destroy", "Queue the destruction of a droplet"
    def destroy
      droplet_name = ask "Enter name of droplet to destroy:"
      say
      say "Warning! Potentially destructive action.", :red
      confirm = yes? "Confirm destruction of '#{droplet_name}' [y,n]"

      raise Thor::Error.new "Response was no - destroy aborted" if !confirm

      say "Destroying '#{droplet_name}'...", :yellow
      say "Succesfully queued destroy for '#{droplet_name}'", :green
    end

    desc "restart", "Restart a droplet"
    def restart(id)
      Middleware.sequence_restart_droplet.call({
        "droplet_id" => id
      })
    end

    desc "halt", "Shutdown a droplet"
    def halt(id)
        Middleware.sequence_halt_droplet.call({
          "droplet_id" => id
        })
    end

    desc "snapshot", "Queue a snapshot of a droplet"
    def snapshot
      ask "Please enter name of snapshot:"
      say "Queuing 'test' snapshot for 'pearkes-admin-001'..."
      say
      say "Succesfully queued snapshot.", :green
    end
  end
end

