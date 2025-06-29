import axios from 'axios'
import { PUBLIC_API_URL } from '$env/static/public'
import type { CreateRoomInput, JoinRoomType } from '$lib'
import { getAuthFromLocalStorage } from '../utils/common.utils'
import type {
	CreateRoomResponse,
	GetAvailableRoomsResponse,
	GetMyRoomsResponse,
	GetRoomResponse,
	JoinRoomResponse
} from '$lib/types'
import { AuthRequest } from '../utils/request.utils'

const request = AuthRequest.create()

export const getAvailableRooms = async () => {
	const { session } = getAuthFromLocalStorage()

	const response = await request.get<GetAvailableRoomsResponse>(
		`${PUBLIC_API_URL}/rooms/available`,
		{
			headers: {
				Authorization: session
			}
		}
	)

	return response.data
}

export const getMyRooms = async () => {
	const { session } = getAuthFromLocalStorage()

	const response = await request.get<GetMyRoomsResponse>(`${PUBLIC_API_URL}/rooms/my`, {
		headers: {
			Authorization: session
		}
	})

	return response.data
}

export const getRoom = async (roomId: string) => {
	const { session } = getAuthFromLocalStorage()

	const response = await request.get<GetRoomResponse>(`${PUBLIC_API_URL}/rooms/${roomId}`, {
		headers: {
			Authorization: session
		}
	})

	return response.data
}

export const createRoom = async (input: CreateRoomInput) => {
	const { session } = getAuthFromLocalStorage()

	const response = await request.post<CreateRoomResponse>(`${PUBLIC_API_URL}/rooms`, input, {
		headers: {
			Authorization: session
		}
	})

	return response.data
}

export const joinRoom = async (room_id: string) => {
	const { session } = getAuthFromLocalStorage()

	const response = await request.post<JoinRoomResponse>(
		`${PUBLIC_API_URL}/rooms/join/${room_id}`,
		{},
		{
			headers: {
				Authorization: session
			}
		}
	)

	return response.data
}
