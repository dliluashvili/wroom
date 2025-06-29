import { PUBLIC_API_URL } from '$env/static/public'
import type { AuthResponse, SignInInput, SignUpInput } from '$lib'
import { GuestRequest } from '../utils/request.utils'

const request = GuestRequest.create()

export const signUp = async (input: SignUpInput) => {
	const response = await request.post<AuthResponse>(`${PUBLIC_API_URL}/auth/sign-up`, input)

	return response.data
}

export const signIn = async (input: SignInInput) => {
	const response = await request.post<AuthResponse>(`${PUBLIC_API_URL}/auth/sign-in`, input)

	return response.data
}
