<script lang="ts">
	import { onMount } from 'svelte'
	import 'video.js/dist/video-js.css'

	import { page } from '$app/state'
	import { getAuthFromLocalStorage } from '../../../utils/common.utils'
	import {
		isWsMediaMessageResponse,
		isWsRoomMessageResponse,
		State,
		WsMessageType,
		type Room,
		type RoomStateInfo,
		type WsMessageResponse,
		type WsRoomMessage
	} from '$lib'
	import { getRoom } from '../../../api'
	import VideoPlayer from '$lib/components/video-player.svelte'

	let room: Room = null
	let socket: WebSocket
	let videoPlayer: VideoPlayer
	let connectionStatus = 'Disconnected'
	let videoElement: HTMLVideoElement
	let isOwner = false
	let showPopup = true
	let joined = false
	let roomStateInfo: RoomStateInfo | null = null
	let eventFromOwner = false

	let maxRetryAttempts: number = 5
	let currentRetryAttempt: number = 0
	let retryTimeout: number | null = null

	const onClickContinue = () => {
		if (connectionStatus === 'Connected' && joined) {
			showPopup = false
			videoPlayer.playAfterContinue(roomStateInfo)
		}
	}

	onMount(async () => {
		const roomId = page.params.roomId

		const { session, user } = getAuthFromLocalStorage()!

		const response = await getRoom(roomId)

		room = response.room

		if (room.user_id === user.id) {
			isOwner = true // TODO: retrieve from the server
		}

		connectToWebSocket()

		function connectToWebSocket() {
			if (retryTimeout !== null) {
				clearTimeout(retryTimeout)
				retryTimeout = null
			}

			socket = new WebSocket(`ws://localhost:3000/socket/room/${roomId}?session=${session}`)

			socket.addEventListener('open', (event) => {
				connectionStatus = 'Connected'

				console.log('Connected to server:', connectionStatus)

				currentRetryAttempt = 0

				const wsMessage: WsRoomMessage = {
					type: WsMessageType.ROOM,
					payload: {
						state: State.JOIN
					}
				}

				socket.send(JSON.stringify(wsMessage))
			})

			socket.addEventListener('message', (event) => {
				const parsedMessage: WsMessageResponse = JSON.parse(event.data)

				console.log('Received message:', parsedMessage)

				if (isWsRoomMessageResponse(parsedMessage)) {
					const { payload } = parsedMessage

					if (payload.state === State.JOIN) {
						joined = true
						roomStateInfo = {
							...roomStateInfo,
							video_current_time: payload.video_current_time,
							is_paused: payload.is_paused
						}
					}
				} else if (isWsMediaMessageResponse(parsedMessage)) {
					const { payload } = parsedMessage

					const networkDelay = (Date.now() - payload.send_time) / 1000

					const adjustedTime = payload.is_paused
						? payload.video_current_time
						: payload.video_current_time + networkDelay

					roomStateInfo = {
						...roomStateInfo,
						video_current_time: adjustedTime,
						is_paused: payload.is_paused
					}

					if (!isOwner) {
						const diff = Math.abs(
							payload.video_current_time - videoPlayer.getCurrenttime()
						)

						if (diff > 1) {
							videoPlayer.setCurrentTime(payload.video_current_time)
						}

						eventFromOwner = true

						if (payload.is_paused) {
							videoPlayer.pause(eventFromOwner)
						} else {
							videoPlayer.play(eventFromOwner)
						}

						eventFromOwner = false
					}
				}
			})

			socket.addEventListener('close', (event) => {
				console.log('disconnected from server', event)
				console.log('disc code', event.code)

				connectionStatus = 'Disconnected'

				if (event.code === 1006 || (event.code !== 1000 && event.code !== undefined)) {
					attemptReconnect()
				}
			})

			socket.addEventListener('error', (event) => {
				connectionStatus = 'Error'
				console.log('error')
				console.error('WebSocket error:', event)
			})
		}

		function attemptReconnect() {
			// Check if we've exceeded max retries
			if (currentRetryAttempt >= maxRetryAttempts) {
				console.log(
					`Maximum retry attempts (${maxRetryAttempts}) reached. Please refresh the page.`
				)
				return
			}

			// Calculate delay with exponential backoff (1s, 2s, 4s, 8s, 16s)
			// Add small random jitter to prevent all clients reconnecting at the same time
			const delay =
				Math.min(1000 * Math.pow(2, currentRetryAttempt), 30000) + Math.random() * 1000

			currentRetryAttempt++

			console.log(
				`Attempting to reconnect (${currentRetryAttempt}/${maxRetryAttempts}) in ${Math.round(delay / 1000)} seconds...`
			)
			connectionStatus = `Reconnecting (${currentRetryAttempt}/${maxRetryAttempts})...`

			// Schedule reconnection attempt
			retryTimeout = window.setTimeout(() => {
				console.log('Attempting to reconnect now...')
				connectToWebSocket()
			}, delay)
		}
	})
</script>

<div class="container-fluid px-4 py-4">
	<div class="flex justify-between items-center mb-4">
		<h1 class="text-2xl font-bold text-black">Movie Night Room</h1>
		<div class="flex gap-2">
			<a
				href="/rooms"
				class="btn bg-indigo-600 hover:bg-indigo-700 text-white border-none btn-sm"
			>
				Leave Room
			</a>
		</div>
	</div>

	<div class="grid grid-cols-12 gap-4 h-[calc(100vh-12rem)] max-w-full">
		{#if room}
			<div class="col-span-10 bg-black rounded-lg shadow-lg overflow-hidden h-[500px]">
				{#if socket}
					<VideoPlayer
						bind:this={videoPlayer}
						src={room.url}
						{roomStateInfo}
						{isOwner}
						{socket}
					/>
				{:else}
					<div>Loading socket connection...</div>
				{/if}

				<!-- <video
				bind:this={videoElement}
				class="w-full h-full object-contain"
				width="100%"
				controls
				muted
			>
				<track kind="captions" label="English" srclang="en" />
				Your browser does not support the video tag.
			</video> -->
			</div>
		{/if}

		<!-- Chat Sidebar - Takes up 2/12 columns -->
		<div class="col-span-2 bg-white rounded-lg shadow-lg flex flex-col overflow-hidden">
			<div class="p-4 bg-indigo-600 text-white font-bold">Chat (8 viewers)</div>

			<div class="flex-grow p-4 overflow-y-auto">
				<div class="mb-2">
					<span class="font-bold">User1:</span>
					<span>Hey everyone, movie night!</span>
					<div class="text-xs text-gray-500">7:30 PM</div>
				</div>
				<div class="mb-2">
					<span class="font-bold">User2:</span>
					<span>The video quality is great</span>
					<div class="text-xs text-gray-500">7:32 PM</div>
				</div>
				<div class="mb-2">
					<span class="font-bold">You:</span>
					<span>Thanks for joining</span>
					<div class="text-xs text-gray-500">7:35 PM</div>
				</div>
			</div>

			<!-- Message Input Area with Balanced Button Size for Narrow Chat -->
			<div class="p-2 border-t">
				<div class="grid grid-cols-1 gap-2">
					<input
						type="text"
						placeholder="Type..."
						class="input input-sm input-bordered input-sm w-full"
					/>
					<button
						class="btn btn-sm bg-indigo-600 hover:bg-indigo-700 text-white border-none w-full"
					>
						Send
					</button>
				</div>
			</div>
		</div>
	</div>
</div>

{#if showPopup}
	<div class="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center">
		{#if connectionStatus !== 'Connected'}
			<span class="loading loading-infinity loading-xs"></span>
		{:else}
			<div class="bg-white rounded-lg p-6 shadow-xl max-w-sm mx-auto">
				<h3 class="text-lg font-bold mb-4">Room is ready, do you want to continue?</h3>

				<div class="mt-6 flex justify-end">
					<button
						on:click={onClickContinue}
						class="btn btn-sm bg-indigo-600 hover:bg-indigo-700 text-white border-none"
					>
						Continue
					</button>
				</div>
			</div>
		{/if}
	</div>
{/if}
