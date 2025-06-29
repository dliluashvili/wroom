import { writable } from 'svelte/store'
import { browser } from '$app/environment'

// Initialize from localStorage if in browser
const storedAuth = browser ? localStorage.getItem('auth') : null
const initialState = storedAuth ? JSON.parse(storedAuth) : null

// Create the global store
export const authStore = writable(initialState)

// Subscribe to changes and update localStorage
if (browser) {
	authStore.subscribe((value) => {
		if (value) {
			localStorage.setItem('auth', JSON.stringify(value))
		} else {
			localStorage.removeItem('auth')
		}
	})
}
