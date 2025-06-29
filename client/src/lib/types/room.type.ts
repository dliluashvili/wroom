import type { Infer } from '@vinejs/vine/types'
import type { CreateRoomSchema, JoinRoomSchema } from '../../schemas'
import type { State } from './ws-message.type'

export interface Room {
	id: string
	user_id: number
	name: string
	is_private: boolean
	capacity: number
	url: string
	created_at: string
}

export type Rooms = Array<Room>

export type CreateRoomInput = Infer<typeof CreateRoomSchema>

export type JoinRoomType = Infer<typeof JoinRoomSchema>

export interface CreateRoomResponse {
	success: boolean
	room: Room
}

export interface GetAvailableRoomsResponse {
	success: boolean
	rooms: Rooms
}

export interface GetMyRoomsResponse extends GetAvailableRoomsResponse {}

export interface GetRoomResponse {
	success: boolean
	room: Room
}

export interface JoinRoomResponse {
	success: boolean
	room_id: string
}

export interface RoomStateInfo {
	video_current_time?: number
	muted?: false
	state?: State
	is_paused?: boolean
}
