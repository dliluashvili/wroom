import type { User } from './user.type'

export interface SignUpInput {
	username: string
	fullname: string
	password: string
	email: string
}

export interface SignInInput {
	username: string
	password: string
}

export interface AuthResponse {
	session_id: string
	user: User
}

export interface AuthStorage {
	session: string
	user: User
}
