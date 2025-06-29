<script lang="ts">
	import { State, WsMessageType, type RoomStateInfo, type WsMediaMessage } from '$lib/types'
	import { onMount, onDestroy } from 'svelte'
	import videojs from 'video.js'
	import type Player from 'video.js/dist/types/player'
	import 'video.js/dist/video-js.css'
	import { formatVideoTime } from '../../utils/time.utils'

	// Props
	export let src: string = ''
	export let roomStateInfo: RoomStateInfo | null = null
	export let socket: WebSocket
	export let isOwner: boolean = false

	let lastUpdateTime = 0
	const UPDATE_INTERVAL = 10000 // 10 seconds

	let videoElement: HTMLVideoElement
	let player: Player | null
	let isUserAction: boolean = false
	let eventFromSystem: boolean = false
	const delay = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms))

	export function playAfterContinue(roomStateInfo: RoomStateInfo) {
		if (!player) false

		player.currentTime(roomStateInfo.video_current_time)
		player.muted(false)

		if (roomStateInfo.state === State.PLAY) {
			player.play()
		} else if (roomStateInfo.state === State.PAUSE) {
			player.pause()
		}
	}

	export function setCurrentTime(time: number) {
		if (player) {
			player.currentTime(time)
		}
	}

	export function getCurrenttime() {
		return player.currentTime()
	}

	export function play(eventFromOwner: boolean): void {
		if (player) {
			if (eventFromOwner) isUserAction = false
			player.play()
		}
	}

	export function pause(eventFromOwner: boolean): void {
		if (player) {
			if (eventFromOwner) isUserAction = false
			player.pause()
		}
	}

	onMount(() => {
		if (!videoElement) return

		player = videojs(videoElement, {
			autoplay: false,
			muted: true,
			disablePictureInPicture: true,
			enableSmoothSeeking: true,
			controls: true,
			controlBar: {
				playToggle: isOwner ? true : false,

				// Enable only specific controls
				progressControl: true,
				volumePanel: true,

				// Disable other controls
				currentTimeDisplay: true,
				timeDivider: true,
				durationDisplay: true,
				remainingTimeDisplay: true,
				customControlSpacer: true,
				chaptersButton: true,
				descriptionsButton: true,
				subsCapsButton: true,
				audioTrackButton: true,
				fullscreenToggle: true,
				pictureInPictureToggle: true,
				liveDisplay: true
			}
		})

		player.ready(function (this: Player) {
			const duration = this.duration()

			if ((this as any).controlBar && (this as any).controlBar.progressControl) {
				;(this as any).controlBar.progressControl.disable()
			}

			this.on('play', async function (this: Player) {
				if (isOwner) {
					const currentTime = this.currentTime()
					const wsMessage: WsMediaMessage = {
						type: WsMessageType.MEDIA,
						payload: {
							state: State.PLAY,
							video_current_time: currentTime,
							is_paused: videoElement.paused,
							formatedVideoTime: formatVideoTime(currentTime, duration),
							send_time: Date.now()
						}
					}

					socket.send(JSON.stringify(wsMessage))
				} else {
					if (roomStateInfo.is_paused) {
						this.currentTime(roomStateInfo.video_current_time)
						this.pause()
					}
				}
			})

			// this.on('seeked', async function () {
			// 	if (isUserAction) {
			// 		this.currentTime(roomStateInfo.video_current_time)
			// 		isUserAction = false
			// 	} else {
			// 		isUserAction = true
			// 	}
			// })

			this.on('pause', async function (this: Player) {
				if (isOwner) {
					const currentTime = this.currentTime()
					const data: WsMediaMessage = {
						type: WsMessageType.MEDIA,
						payload: {
							state: State.PAUSE,
							video_current_time: currentTime,
							is_paused: videoElement.paused,
							formatedVideoTime: formatVideoTime(currentTime, duration),
							send_time: Date.now()
						}
					}

					socket.send(JSON.stringify(data))
				} else {
					if (!roomStateInfo.is_paused) {
						this.currentTime(roomStateInfo.video_current_time)
						this.play()
					}
				}
			})

			if (isOwner) {
				videoElement.addEventListener('timeupdate', function (this: Player) {
					const now = Date.now()

					if (now - lastUpdateTime > UPDATE_INTERVAL) {
						lastUpdateTime = now

						const currentTime = videoElement.currentTime

						const wsMessage: WsMediaMessage = {
							type: WsMessageType.MEDIA,
							payload: {
								state: State.TIME_UPDATE,
								video_current_time: currentTime,
								is_paused: videoElement.paused,
								formatedVideoTime: formatVideoTime(currentTime, duration),
								send_time: Date.now()
							}
						}

						socket.send(JSON.stringify(wsMessage))
					}
				})
			}

			this.on('contextmenu', function (e: Event) {
				e.preventDefault()
				e.stopPropagation()
			})
		})

		if (src) {
			player.src({
				src: src,
				type: inferTypeFromSrc(src)
			})
		}
	})

	onDestroy(() => {
		if (player) {
			player.dispose()
		}
	})

	function inferTypeFromSrc(src: string): string {
		if (!src) return ''
		if (src.includes('.mp4')) return 'video/mp4'
		if (src.includes('.webm')) return 'video/webm'
		if (src.includes('.ogv')) return 'video/ogg'
		if (src.includes('.m3u8')) return 'application/x-mpegURL'
		if (src.includes('.mpd')) return 'application/dash+xml'
		return ''
	}
</script>

<div class="video-container">
	<!-- svelte-ignore a11y-media-has-caption -->
	<video width="100%" bind:this={videoElement} class="video-js vjs-big-play-centered"></video>
</div>

<style>
	/* Make sure the container takes up full width */
	.video-container {
		width: 100%;
		height: 100%;
	}

	/* Ensure the video element itself also takes full width */
	:global(.video-js) {
		width: 100% !important;
		height: 100% !important;
		min-height: 300px;
	}
</style>
