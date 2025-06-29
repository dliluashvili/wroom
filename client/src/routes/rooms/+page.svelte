<script lang="ts">
	import vine, { errors } from '@vinejs/vine'
	import { CreateRoomSchema, JoinRoomSchema } from '../../schemas'
	import { createRoom, getAvailableRooms, joinRoom } from '../../api'
	import { actualizeVineClientSideErrors } from '../../utils/common.utils'
	import { onMount } from 'svelte'
	import type { Rooms } from '$lib'
	import { writable } from 'svelte/store'
	import { goto } from '$app/navigation'

	let isModalOpen = false

	function openModal() {
		isModalOpen = true
	}

	function closeModal() {
		isModalOpen = false
	}

	const rooms = writable<Rooms>([])

	let fieldErrors: Record<string, string[]> | null = null

	async function handleSubmit(event: SubmitEvent) {
		event.preventDefault()
		const form = event.target as HTMLFormElement
		const formData = new FormData(form)
		const data = {
			name: formData.get('name') as string,
			capacity: formData.get('capacity') as string,
			is_private: formData.get('is_private') as string,
			url: formData.get('url') as string
		}

		fieldErrors = null

		try {
			const validated = await vine.validate({
				schema: CreateRoomSchema,
				data
			})

			await createRoom(validated)
		} catch (e) {
			if (e instanceof errors.E_VALIDATION_ERROR) {
				fieldErrors = actualizeVineClientSideErrors(e)
			}

			console.log('fieldErrors', fieldErrors)
		}
	}

	const handleJoinRoom = async (roomId: string) => {
		try {
			const validated = await vine.validate({
				schema: JoinRoomSchema,
				data: { room_id: roomId }
			})

			const result = await joinRoom(validated.room_id)

			if (result.success) {
				goto(`/rooms/${roomId}`)
			}
		} catch (e) {
			if (e instanceof errors.E_VALIDATION_ERROR) {
				console.log(e.messages)
			}
		}
	}

	onMount(async () => {
		getAvailableRooms().then(({ success, rooms: _rooms }) => {
			if (success) {
				rooms.update((currentRooms) => [...currentRooms, ..._rooms])
			}
		})
	})
</script>

<main class="container mx-auto px-4">
	<div class="flex justify-between items-center mb-8">
		<h1 class="text-2xl font-bold text-black">Available Rooms</h1>
		<button
			class="btn btn-xs bg-indigo-600 hover:bg-indigo-700 text-white border-none"
			on:click={openModal}
		>
			Create a Room
		</button>
	</div>

	<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
		{#each $rooms as room}
			<div class="bg-white rounded-lg shadow-lg p-6">
				<h2 class="text-xl font-bold mb-2">{room.name}</h2>
				<p class="mb-4">A cozy space for relaxing</p>
				<button
					on:click={() => handleJoinRoom(room.id)}
					class="w-full btn btn-xs bg-indigo-600 hover:bg-indigo-700 text-white border-none"
					>Join</button
				>
			</div>
		{/each}
	</div>
</main>

<!-- Create Room Modal -->
{#if isModalOpen}
	<div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
		<div class="bg-white rounded-lg shadow-xl p-6 w-full max-w-md">
			<h2 class="text-2xl font-bold mb-4">Create a Watch Room</h2>

			<form on:submit|preventDefault={handleSubmit}>
				<!-- Room Name -->
				<div class="form-control">
					<label class="label" for="name">
						<span class="label-text label-text-xs">Room Name</span>
					</label>
					<input
						type="text"
						id="name"
						name="name"
						placeholder="Enter room name"
						class="input input-xs input-bordered w-full"
						required
					/>
					<div class="label pt-1">
						<span class="label-text-alt text-error">{fieldErrors?.fullname}</span>
					</div>
				</div>

				<div class="form-control">
					<label class="label cursor-pointer">
						<span class="label-text label-text-xs">Private Room</span>
						<input type="checkbox" name="is_private" class="checkbox checkbox-xs" />
					</label>

					<div class="label pt-1">
						<span class="label-text-alt text-error">{fieldErrors?.fullname}</span>
					</div>
				</div>

				<!-- Max People -->
				<div class="form-control">
					<label class="label" for="capacity">
						<span class="label-text label-text-xs">Maximum Number of People</span>
					</label>
					<input
						type="number"
						id="capacity"
						min="1"
						max="20"
						name="capacity"
						class="input input-xs input-bordered w-full"
						required
					/>

					<div class="label pt-1">
						<span class="label-text-alt text-error">{fieldErrors?.fullname}</span>
					</div>
				</div>

				<div class="form-control">
					<label class="label" for="url">
						<span class="label-text label-text-xs">Url</span>
					</label>
					<input
						type="text"
						id="url"
						name="url"
						placeholder="Enter url"
						class="input input-xs input-bordered w-full"
						required
					/>

					<div class="label pt-1">
						<span class="label-text-alt text-error">{fieldErrors?.fullname}</span>
					</div>
				</div>

				<!-- Buttons -->
				<div class="flex justify-end gap-2 mt-6">
					<button type="button" class="btn btn-xs btn-outline" on:click={closeModal}>
						Cancel
					</button>
					<button
						type="submit"
						class="btn btn-xs bg-indigo-600 hover:bg-indigo-700 text-white border-none"
					>
						Create Room
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}
