import vine from '@vinejs/vine'

export const CreateRoomSchema = vine.object({
	name: vine.string().minLength(2).maxLength(32),
	is_private: vine.boolean(),
	capacity: vine.number().min(2).max(20),
	url: vine.string().minLength(2)
})

export const JoinRoomSchema = vine.object({
	room_id: vine.string().uuid()
})
