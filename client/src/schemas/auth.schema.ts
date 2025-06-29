import vine from '@vinejs/vine'

export const SignUpInputSchema = vine.object({
	fullname: vine.string().minLength(2).maxLength(32),
	username: vine.string().minLength(2).maxLength(32).toLowerCase(),
	email: vine.string().email(),
	password: vine.string().minLength(8).maxLength(32)
})

export const SignInInputSchema = vine.object({
	username: vine.string().minLength(2).maxLength(32).toLowerCase(),
	password: vine.string().minLength(8).maxLength(32)
})
