export enum WsMessageType {
	ROOM = 'ROOM',
	MEDIA = 'MEDIA',
	CHAT = 'CHAT',
	PONG = 'PONG',
	PING = 'PING'
}

export enum State {
	INIT = 'INIT',
	PLAY = 'PLAY',
	PAUSE = 'PAUSE',
	SEEK = 'SEEK',
	TIME_UPDATE = 'TIME_UPDATE',
	LATEST_STATE = 'LATEST_STATE',
	JOIN = 'JOIN',
	END = 'END'
}

export interface WsRoomMessage {
	type: WsMessageType.ROOM
	payload: {
		state: State.JOIN
	}
}

export interface WsMediaMessage {
	type: WsMessageType.MEDIA
	payload: {
		state: State.INIT | State.PLAY | State.PAUSE | State.SEEK | State.TIME_UPDATE | State.END
		video_current_time: number
		is_paused: boolean
		formatedVideoTime: string
		send_time: number //seconds
	}
}

export type WsMessage = WsRoomMessage | WsMediaMessage

export const isWsRoomMessage = (message: WsMessage): message is WsRoomMessage => {
	return message.type === WsMessageType.ROOM
}

export const isWsMediaMessage = (message: WsMessage): message is WsMediaMessage => {
	return message.type === WsMessageType.MEDIA
}

export interface WsRoomMessageResponse {
	type: WsMessageType.ROOM
	payload: {
		state: State.JOIN
		video_current_time: number
		is_paused: boolean
	}
}

export interface WsMediaMessageResponse {
	type: WsMessageType.MEDIA
	payload: {
		state: State.INIT | State.PLAY | State.PAUSE | State.SEEK | State.TIME_UPDATE | State.END
		video_current_time: number
		is_paused: boolean
		formatedVideoTime: string
		send_time: number
	}
}

export type WsMessageResponse = WsRoomMessageResponse | WsMediaMessageResponse

export const isWsRoomMessageResponse = (
	message: WsMessageResponse
): message is WsRoomMessageResponse => {
	return message.type === WsMessageType.ROOM
}

export const isWsMediaMessageResponse = (
	message: WsMessageResponse
): message is WsMediaMessageResponse => {
	return message.type === WsMessageType.MEDIA
}
