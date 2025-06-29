<script>
	import 'tailwindcss/tailwind.css'
	import '../app.css'
	import { authStore } from '$lib/stores'
	import { browser } from '$app/environment'
	import { page } from '$app/state'
	import { goto } from '$app/navigation'

	let isAuthenticated = false
	let currentPath = browser ? page.url.pathname : ''

	if (browser) {
		authStore.subscribe((value) => {
			isAuthenticated = !!value?.session
		})

		const path = page.url.pathname
		const authPaths = ['/auth/sign-in', '/auth/sign-up']

		if (authPaths.includes(path) && isAuthenticated) {
			goto('/rooms', { replaceState: true })
		}

		if (!authPaths.includes(path) && !isAuthenticated) {
			goto('/auth/sign-in', { replaceState: true })
		}
	}
</script>

<div class="min-h-screen bg-base-200">
	<header class="bg-white shadow-md p-4 mb-8">
		<div class="container mx-auto">
			<nav class="flex items-center justify-between">
				<div class="flex items-center gap-8">
					<div class="font-bold text-xl">RoomChat</div>
					<ul class="flex gap-2">
						<li>
							<button
								onclick={() => {
									if (isAuthenticated) {
										currentPath = '/'
										goto('/', { replaceState: true })
									} else {
										return false
									}
								}}
								class="btn btn-xs btn-{currentPath === '/' ? 'primary' : 'outline'}"
								>Home</button
							>
						</li>
						<li>
							<button
								onclick={() => {
									if (isAuthenticated) {
										currentPath = '/rooms'
										goto('rooms', { replaceState: true })
									} else {
										return false
									}
								}}
								class="btn btn-xs btn-{currentPath.includes('/rooms')
									? 'primary'
									: 'outline'}">Rooms</button
							>
						</li>
					</ul>
				</div>

				<div>
					{#if isAuthenticated}
						<a href="/profile" class="hover:text-primary">Profile</a>
					{:else}
						<div class="flex gap-3">
							<a
								data-link={currentPath}
								onclick={() => {
									currentPath = '/auth/sign-in'
								}}
								href="/auth/sign-in"
								class="btn btn-xs btn-{currentPath.includes('sign-in')
									? 'primary'
									: 'outline'}">Sign In</a
							>
							<a
								href="/auth/sign-up"
								onclick={() => {
									currentPath = '/auth/sign-up'
								}}
								class="btn btn-xs btn-{currentPath.includes('sign-up')
									? 'primary'
									: 'outline'}">Sign Up</a
							>
						</div>
					{/if}
				</div>
			</nav>
		</div>
	</header>
	<slot />
</div>
