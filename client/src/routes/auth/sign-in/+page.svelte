<script lang="ts">
	import vine, { errors } from '@vinejs/vine'
	import { signIn } from '../../../api'
	import { SignInInputSchema } from '../../../schemas'
	import { onMount } from 'svelte'
	import { actualizeVineClientSideErrors } from '../../../utils/common.utils'
	import { authStore } from '$lib/stores'
	import { goto } from '$app/navigation'

	let fieldErrors: Record<string, string[]> | null = null

	async function handleSubmit(event: SubmitEvent) {
		event.preventDefault()
		const form = event.target as HTMLFormElement
		const formData = new FormData(form)
		const data = {
			username: formData.get('username') as string,
			password: formData.get('password') as string
		}

		fieldErrors = null

		try {
			const validatedData = await vine.validate({ schema: SignInInputSchema, data })

			const { session_id, user } = await signIn(validatedData)

			authStore.set({
				session: session_id,
				user: user
			})

			goto('/rooms', { replaceState: true })
		} catch (e) {
			if (e instanceof errors.E_VALIDATION_ERROR) {
				fieldErrors = actualizeVineClientSideErrors(e)
				console.log(fieldErrors)
			}
		}
	}

	onMount(() => {
		fieldErrors = null
	})
</script>

<div class="flex justify-center items-center h-full py-6">
	<div class="card w-96 bg-base-100 shadow-sm">
		<div class="card-body p-6">
			<h2 class="text-xl font-medium mb-4">Sign In</h2>

			{#if fieldErrors}
				<div role="alert" class="alert alert-xs alert-error">
					<svg
						xmlns="http://www.w3.org/2000/svg"
						class="h-6 w-6 shrink-0 stroke-current"
						fill="none"
						viewBox="0 0 24 24"
					>
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"
						/>
					</svg>
					<p class="ml-2">There was an error creating your account.</p>
				</div>
			{/if}
			<form on:submit|preventDefault={handleSubmit}>
				<div>
					<!-- Username field -->
					<label class="form-control">
						<div class="label">
							<span class="label-text label-text-xs">Username</span>
						</div>
						<input
							type="text"
							class="input input-sm input-xs input-bordered w-full {fieldErrors?.username
								? 'input-error'
								: ''}"
							placeholder="johndoe"
							name="username"
						/>
						<div class="label pt-1">
							<span class="label-text-alt text-error">{fieldErrors?.username}</span>
						</div>
					</label>

					<!-- Password field -->
					<label class="form-control">
						<div class="label">
							<span class="label-text label-text-xs">Password</span>
						</div>
						<input
							type="password"
							class="input input-sm input-xs input-bordered w-full {fieldErrors?.password
								? 'input-error'
								: ''}"
							placeholder="••••••••"
							name="password"
						/>
						<div class="label pt-1">
							<span class="label-text-alt text-error">{fieldErrors?.password}</span>
						</div>
					</label>

					<!-- Submit button -->
					<button type="submit" class="btn btn-xs btn-primary w-full mt-4">
						Login
					</button>
				</div>
			</form>
		</div>
	</div>
</div>
