// src/utils/request.utils.ts
import axios, { type AxiosInstance } from 'axios'
import { PUBLIC_API_URL } from '$env/static/public'
import { getAuthFromLocalStorage, clearAuth } from './common.utils'
import { goto } from '$app/navigation' // For SvelteKit navigation
import { browser } from '$app/environment'

/**
 * Singleton class for authenticated API requests
 */
export class AuthRequest {
	private static instance: AxiosInstance | null = null

	/**
	 * Creates or returns an existing axios instance for authenticated requests
	 */
	public static create(): AxiosInstance | never {
		if (browser) {
			if (AuthRequest.instance) {
				return AuthRequest.instance
			}

			const authState = getAuthFromLocalStorage()

			if (!authState) {
				console.log('No auth state found in local storage')
				throw new Error('No auth state found')
			}

			const axiosInstance = axios.create({
				baseURL: PUBLIC_API_URL,
				headers: {
					'Content-Type': 'application/json',
					Authorization: authState?.session
				}
			})

			// Add a response interceptor to handle 401 errors
			axiosInstance.interceptors.response.use(
				(response) => response,
				(error) => {
					if (error.response && error.response.status === 401) {
						console.log('Unauthorized request - session expired or invalid')
						clearAuth()
						goto('/login')
					}

					return Promise.reject(error)
				}
			)

			AuthRequest.instance = axiosInstance

			return axiosInstance
		}
	}

	/**
	 * Resets the instance (useful after logout or token change)
	 */
	public static reset(): void {
		AuthRequest.instance = null
	}
}

/**
 * Singleton class for guest (unauthenticated) API requests
 */
export class GuestRequest {
	private static instance: AxiosInstance | null = null

	/**
	 * Creates or returns an existing axios instance for guest requests
	 */
	public static create(): AxiosInstance {
		if (GuestRequest.instance) {
			return GuestRequest.instance
		}

		const axiosInstance = axios.create({
			baseURL: PUBLIC_API_URL,
			headers: {
				'Content-Type': 'application/json'
			}
		})

		GuestRequest.instance = axiosInstance

		return axiosInstance
	}

	/**
	 * Resets the instance
	 */
	public static reset(): void {
		GuestRequest.instance = null
	}
}
