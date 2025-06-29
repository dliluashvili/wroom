import { browser } from '$app/environment'
import type { AuthStorage } from '$lib'
import { authStore } from '$lib/stores'
import { errors } from '@vinejs/vine'

export type VineValidationError = InstanceType<typeof errors.E_VALIDATION_ERROR>

export const actualizeVineClientSideErrors = (validationErrors: VineValidationError) => {
	const actualizedErrors: Record<string, string[]> = {}

	for (const { field, message } of validationErrors.messages) {
		if (!actualizedErrors[field]) {
			actualizedErrors[field] = []
		}

		actualizedErrors[field].push(message)
	}

	return actualizedErrors
}

export const getAuthFromLocalStorage = (): AuthStorage | null => {
	if (browser) {
		const auth = JSON.parse(localStorage.getItem('auth') || '{}')

		return auth as AuthStorage
	}

	return null
}

export const clearAuth = () => {
	authStore.set({
		session: null
	})
}
