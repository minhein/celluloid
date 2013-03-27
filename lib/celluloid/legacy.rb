module Celluloid
  class ActorProxy
    # method_missing black magic to call bang predicate methods asynchronously
    def method_missing(meth, *args, &block)
      # bang methods are async calls
      if meth.match(/!$/)
        Logger.deprecate("'bang method'-style async syntax is deprecated and will be removed in Celluloid 1.0." +
          "Call async methods with 'actor.async.method'.")

        unbanged_meth = meth.to_s
        unbanged_meth.slice!(-1, 1)
        async unbanged_meth, *args, &block
      else
        sync meth, *args, &block
      end
    end
  end

  module InstanceMethods
    # Process async calls via method_missing
    def method_missing(meth, *args, &block)
      # bang methods are async calls
      if meth.to_s.match(/!$/)
        Logger.deprecate("'bang method'-style async syntax is deprecated and will be removed in Celluloid 1.0." +
          "Call async methods with 'actor.async.method'.")

        unbanged_meth = meth.to_s.sub(/!$/, '')
        args.unshift unbanged_meth

        Actor.async Thread.current[:celluloid_actor].mailbox, :__send__, *args, &block
        return
      end

      super
    end
  end
end
