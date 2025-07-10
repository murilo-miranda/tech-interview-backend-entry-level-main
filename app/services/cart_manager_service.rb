class CartManagerService	
	attr_reader :action
	
	SERVICE = {
		show: CartFinderService,
		create: CartItemRegisterService,
		add_item: CartItemUpdaterService,
		remove_item: CartItemDeleterService
	}
	def initialize(session:, cart_params:, action:)
		@session = session || {}
		@cart_params = cart_params
		@action = action.to_sym
	end
	
	def self.call(session:, cart_params:, action:)
		cart_manager = new(session: session, cart_params: cart_params, action: action)

		SERVICE[cart_manager.action].call(**cart_manager.params)
	end
	def params
		{
			session: @session,
			cart_params: @cart_params
		}
	end
end