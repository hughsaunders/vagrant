module VagrantPlugins
  module ProviderVirtualBox
    module Action
      class Clone
        def initialize(app, env)
          @app = app
        end

        def call(env)
            source_vm = env[:machine].provider_config.source_vm
          env[:ui].info I18n.t(
            "vagrant.actions.vm.clone.cloning",
            :source_vm => source_vm 
          )

          # Clone the virtual machine
          env[:machine].id = env[:machine].provider.driver.clone(source_vm)

          raise Vagrant::Errors::VMImportFailure if !env[:machine].id

          # Import completed successfully. Continue the chain
          @app.call(env)
        end

        def recover(env)
          if env[:machine].provider.state.id != :not_created
            return if env["vagrant.error"].is_a?(Vagrant::Errors::VagrantError)

            # Interrupted, destroy the VM. We note that we don't want to
            # validate the configuration here, and we don't want to confirm
            # we want to destroy.
            destroy_env = env.clone
            destroy_env[:config_validate] = false
            destroy_env[:force_confirm_destroy] = true
            env[:action_runner].run(Action.action_destroy, destroy_env)
          end
        end
      end
    end
  end
end
